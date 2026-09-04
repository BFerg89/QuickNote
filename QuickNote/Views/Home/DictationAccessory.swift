//
//  DictationAccessory.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-09-02.
//

import SwiftUI

struct DictationAccessory: View {
    var startedAt: Date
    let stopRecording: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.red)
                .frame(width: 34, height: 34)
                .background(.red.opacity(0.12), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text("Listening")
                        .fontWeight(.semibold)

                    Text("·")
                        .foregroundStyle(.tertiary)

                    Text(
                        timerInterval: startedAt...Date.distantFuture,
                        countsDown: false,
                        showsHours: false
                    ) // Placeholder for elapsed time
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .font(.caption)

                Text("Call John tomorrow") // Placeholder for live transcription
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .accessibilityElement(children: .combine)

            Spacer(minLength: 4)

            Button(action: stopRecording) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Stop recording")
        }
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .padding(.vertical, 6)
    }
}

#Preview {
    DictationAccessory(startedAt: Date.now) {
        return
    }
}
