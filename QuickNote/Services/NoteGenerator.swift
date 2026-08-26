//
//  NoteGenerator.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-23.
//

import Foundation
import FirebaseAILogic

enum NoteGenerator {
    private static let ai = FirebaseAI.firebaseAI(backend: .googleAI())
    private static let model = ai.geminiModel(name: "gemini-3.5-flash-lite")
    
    static func generate(from rawText: String) async throws -> GeneratedNote {
        let session = ai.generativeModelSession(
            model: model,
            instructions: NoteProcessingPrompt.instructions()
        )
        
        let response = try await session.respond(
            to: NoteProcessingPrompt.request(for: rawText),
            generating: GeneratedNote.self
        )
        
        return response.content
    }
}
