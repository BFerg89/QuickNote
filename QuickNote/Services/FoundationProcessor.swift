//
//  FoundationProcessor.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-23.
//

import Foundation
import FoundationModels

enum FoundationProcessor {
    private static let model = SystemLanguageModel.default

    static var isAvailable: Bool {
        model.isAvailable
    }

    static func process(_ rawText: String) async throws -> GeneratedNote {
        let currentDateTime = Date.now.formatted(
            date: .complete,
            time: .complete
        )
        let currentTimeZone = TimeZone.current.identifier

        let session = LanguageModelSession(model: model, instructions: NoteProcessingPrompt.instructions())
        
        let response = try await session.respond(
            to: NoteProcessingPrompt.request(for: rawText),
            generating: GeneratedNote.self
        )

        return response.content
    }
}
