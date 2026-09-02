//
//  DictationService.swift
//  QuickNote
//

import AVFAudio
import Foundation
import Speech

@MainActor
public final class DictationService {
    public enum ServiceError: LocalizedError {
        case alreadyActive
        case notRecording
        case stopAlreadyInProgress
        case cancelled
        case microphonePermissionDenied
        case speechRecognitionPermissionDenied
        case recognizerUnavailable
        case audioSessionFailed
        case audioCaptureFailed
        case recognitionFailed

        public var errorDescription: String? {
            switch self {
            case .alreadyActive:
                "A dictation session is already active."
            case .notRecording:
                "There is no active dictation session to stop."
            case .stopAlreadyInProgress:
                "The dictation session is already stopping."
            case .cancelled:
                "The dictation session was cancelled."
            case .microphonePermissionDenied:
                "Microphone access is required for dictation."
            case .speechRecognitionPermissionDenied:
                "Speech recognition access is required for dictation."
            case .recognizerUnavailable:
                "Speech recognition is currently unavailable."
            case .audioSessionFailed:
                "The audio session could not be configured for dictation."
            case .audioCaptureFailed:
                "Microphone capture could not be started."
            case .recognitionFailed:
                "Speech recognition failed."
            }
        }
    }

    private enum Lifecycle {
        case idle
        case starting(UUID)
        case recording(UUID)
        case stopping(UUID)
        case terminal(UUID)
    }

    private let audioEngine = AVAudioEngine()

    private var lifecycle = Lifecycle.idle
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var terminalResult: Result<String, ServiceError>?
    private var stopContinuation: CheckedContinuation<String, any Error>?
    private var hasAudioTap = false
    private var isAudioSessionActive = false

    public init() {}

    deinit {
        audioEngine.stop()
        if hasAudioTap {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        if isAudioSessionActive {
            try? AVAudioSession.sharedInstance().setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
        }
    }

    public func start() async throws {
        guard case .idle = lifecycle else {
            throw ServiceError.alreadyActive
        }

        let sessionID = UUID()
        lifecycle = .starting(sessionID)

        do {
            guard await microphonePermissionGranted() else {
                throw ServiceError.microphonePermissionDenied
            }
            try ensureStillStarting(sessionID)

            guard await speechRecognitionPermissionGranted() else {
                throw ServiceError.speechRecognitionPermissionDenied
            }
            try ensureStillStarting(sessionID)

            guard let recognizer = SFSpeechRecognizer(locale: Locale.current),
                  recognizer.isAvailable else {
                throw ServiceError.recognizerUnavailable
            }

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = false
            request.taskHint = .dictation

            self.recognizer = recognizer
            recognitionRequest = request

            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(
                    .record,
                    mode: .measurement,
                    options: []
                )
                try audioSession.setActive(true)
                isAudioSessionActive = true
            } catch {
                throw ServiceError.audioSessionFailed
            }

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            guard format.sampleRate > 0, format.channelCount > 0 else {
                throw ServiceError.audioCaptureFailed
            }

            inputNode.installTap(
                onBus: 0,
                bufferSize: 1_024,
                format: format
            ) { buffer, _ in
                request.append(buffer)
            }
            hasAudioTap = true

            recognitionTask = recognizer.recognitionTask(with: request) {
                [weak self] result,
                error in
                guard result?.isFinal == true || error != nil else { return }

                let terminalResult: Result<String, ServiceError>
                if let result, result.isFinal {
                    terminalResult = .success(
                        result.bestTranscription.formattedString
                    )
                } else {
                    terminalResult = .failure(.recognitionFailed)
                }

                Task { @MainActor [weak self] in
                    self?.finishRecognition(
                        terminalResult,
                        sessionID: sessionID
                    )
                }
            }

            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch {
                throw ServiceError.audioCaptureFailed
            }

            lifecycle = .recording(sessionID)
        } catch let error as ServiceError {
            cleanUpFailedStart(sessionID: sessionID)
            throw error
        } catch {
            cleanUpFailedStart(sessionID: sessionID)
            throw ServiceError.audioCaptureFailed
        }
    }

    public func stop() async throws -> String {
        switch lifecycle {
        case .idle:
            throw ServiceError.notRecording
        case .starting:
            throw ServiceError.notRecording
        case .stopping:
            throw ServiceError.stopAlreadyInProgress
        case .terminal:
            guard let result = terminalResult else {
                resetSession()
                throw ServiceError.recognitionFailed
            }

            resetSession()
            return try result.get()
        case let .recording(sessionID):
            lifecycle = .stopping(sessionID)
            stopCapture()

            return try await withCheckedThrowingContinuation {
                (continuation: CheckedContinuation<String, any Error>) in
                stopContinuation = continuation
            }
        }
    }

    public func cancel() {
        guard !isIdle else { return }

        lifecycle = .idle
        terminalResult = nil
        stopContinuation?.resume(throwing: ServiceError.cancelled)
        stopContinuation = nil

        stopCapture()
        recognitionTask?.cancel()
        releaseRecognitionResources()
    }

    private var isIdle: Bool {
        if case .idle = lifecycle {
            true
        } else {
            false
        }
    }

    private func microphonePermissionGranted() async -> Bool {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            return true
        case .denied:
            return false
        case .undetermined:
            return await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default:
            return false
        }
    }

    private func speechRecognitionPermissionGranted() async -> Bool {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            let status = await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status)
                }
            }
            return status == .authorized
        @unknown default:
            return false
        }
    }

    private func ensureStillStarting(_ sessionID: UUID) throws {
        guard case let .starting(activeSessionID) = lifecycle,
              activeSessionID == sessionID else {
            throw ServiceError.cancelled
        }
    }

    private func finishRecognition(
        _ result: Result<String, ServiceError>,
        sessionID: UUID
    ) {
        switch lifecycle {
        case let .recording(activeSessionID) where activeSessionID == sessionID:
            lifecycle = .terminal(sessionID)
        case let .stopping(activeSessionID) where activeSessionID == sessionID:
            break
        default:
            return
        }

        terminalResult = result.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        stopCapture()
        releaseRecognitionResources()

        guard let continuation = stopContinuation,
              let terminalResult else {
            return
        }

        resetSession()
        continuation.resume(with: terminalResult)
    }

    private func stopCapture() {
        audioEngine.stop()

        if hasAudioTap {
            audioEngine.inputNode.removeTap(onBus: 0)
            hasAudioTap = false
        }

        recognitionRequest?.endAudio()

        if isAudioSessionActive {
            try? AVAudioSession.sharedInstance().setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
            isAudioSessionActive = false
        }
    }

    private func cleanUpFailedStart(sessionID: UUID) {
        guard case let .starting(activeSessionID) = lifecycle,
              activeSessionID == sessionID else { return }

        lifecycle = .idle
        stopCapture()
        recognitionTask?.cancel()
        releaseRecognitionResources()
        terminalResult = nil
    }

    private func releaseRecognitionResources() {
        recognitionTask = nil
        recognitionRequest = nil
        recognizer = nil
    }

    private func resetSession() {
        lifecycle = .idle
        terminalResult = nil
        stopContinuation = nil
        releaseRecognitionResources()
    }
}
