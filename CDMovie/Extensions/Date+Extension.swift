//
//  Date+Extension.swift
//  CDMovie
//
//  Created by Cagatay on 19.10.2019.
//  Copyright © 2019 Cagatay. All rights reserved.
//

import Foundation

public extension Locale {
    static var TR: Locale {
        return Locale(identifier: "TR");
    }
}

public extension DateFormatter {
    static var networkStandard: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    static var humanReadableDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale.TR
        formatter.doesRelativeDateFormatting = false
        return formatter
    }
}

public func loggingPrint<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG
    let value = object()
    let fileURL = NSURL(string: file)?.lastPathComponent ?? "Unknown file"
    let queue = Thread.isMainThread ? "UI" : "BG"
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss:SSS"
    
    print("CD_LOG <\(queue)> \(fileURL) \(function)[\(line)] \(formatter.string(from: Date())): " + String(reflecting: value) + "\n")
    #endif
}
