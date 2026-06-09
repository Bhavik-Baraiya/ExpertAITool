//
//  Logger.swift
//  ExpertAITool
//
//  Created by Bhavik Baraiya on 08/06/26.
//


import Foundation

class Logger {
    
    static let shared = Logger()
    
    func log(
        content: String
    ) {
        #if DEBUG
            print(content)
        #endif
    }
}
