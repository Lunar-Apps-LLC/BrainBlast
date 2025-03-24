//
//  SimpleLogger.swift
//  FaceSwap
//
//  Created by Andrew Garcia on 11/19/24.
//

import Foundation

let log = SimpleLogger.shared

class SimpleLogger {
    static let shared = SimpleLogger()
    
    var shouldLogDate = false
    var shouldLogFileName = true
    var shouldLogFunctionName = true
    
    func setup(shouldLogDate: Bool = true, shouldLogFileName: Bool = true, shouldLogFunctionName: Bool = true) {
        self.shouldLogDate = shouldLogDate
        self.shouldLogFileName = shouldLogFileName
        self.shouldLogFunctionName = shouldLogFunctionName
    }
    
    func verbose(_ message: @autoclosure () -> Any, _ functionName: String = #function, _ lineNumber: UInt = #line, _ fileName: String = #file) {
        let messageString = "\(message())"
        let emoji = "💬 "
        showMessage(emoji: emoji, message: messageString, functionName, lineNumber, fileName)
    }
    
    func debug(_ message: @autoclosure () -> Any, _ functionName: String = #function, _ lineNumber: UInt = #line, _ fileName: String = #file) {
        let messageString = "\(message())"
        let emoji = "🐞 "
        showMessage(emoji: emoji, message: messageString, functionName, lineNumber, fileName)
    }
    
    func error(_ message: @autoclosure () -> Any, _ functionName: String = #function, _ lineNumber: UInt = #line, _ fileName: String = #file) {
        let messageString = "\(message())"
        let emoji = "💔 "
        showMessage(emoji: emoji, message: messageString, functionName, lineNumber, fileName)
    }
    
    func jsonData(_ data: Data, _ functionName: String = #function, _ lineNumber: UInt = #line, _ fileName: String = #file) {
        if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
            let emoji = "🕸️ "
            showMessage(emoji: emoji, message: JSONString, functionName, lineNumber, fileName)
        }
    }
    
    private func showMessage(emoji: String, message: String, _ functionName: String = #function, _ lineNumber: UInt = #line, _ fileName: String = #file) {
        var fullMessageString = emoji
        
        if shouldLogDate {
            fullMessageString = fullMessageString + Date().formattedISO8601 + " ⇨ "
        }
        
        if shouldLogFileName {
            let fileName = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
            fullMessageString = fullMessageString + fileName + ":"
        }
        
        if shouldLogFunctionName {
            fullMessageString = fullMessageString + functionName.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
            fullMessageString = fullMessageString + ":\(lineNumber)" + " ➡️ "
        }
        
        fullMessageString = fullMessageString + message
        
        print(fullMessageString)
    }
}

extension Foundation.Date {
    struct Date {
        static let formatterISO8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
            return formatter
        }()
    }
    var formattedISO8601: String { return Date.formatterISO8601.string(from: self) }
}
