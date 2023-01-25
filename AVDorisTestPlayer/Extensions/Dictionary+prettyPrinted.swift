//
//  Dictionary+prettyPrinted.swift
//  AVDorisTestPlayer
//
//  Created by Yaroslav Lvov on 25.01.2023.
//  Copyright © 2023 Endeavor Streaming. All rights reserved.
//

import Foundation

extension Dictionary {
    var prettyPrintedJSONString: NSString {
        var options: JSONSerialization.WritingOptions
        if #available(iOS 13.0, *), #available(tvOS 13.0, *) {
            options = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
        } else {
            options = [.sortedKeys, .prettyPrinted]
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: options),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return "" }

        return prettyPrintedString
    }
}
