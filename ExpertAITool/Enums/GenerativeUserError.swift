//
//  GenerativeUserError.swift
//  ExpertAITool
//
//  Created by Bhavik Baraiya on 08/06/26.
//
import Foundation

enum GenerativeUserError: LocalizedError {
    
    case modelNotReady
    case modelDisabled
    case unsupported
    case unknown
    
    var description: String {
        switch self {
            case .modelDisabled:
                "Apple Intelligence is not enabled in Settings. Please enable it in settings to get access of this"
            case .modelNotReady:
                "The model is not ready yet. Please try again later."
            case .unsupported:
                "The model is not available on this device."
            case .unknown:
                "The model is unavailable for an unknown reason."
        }
    }
}
