// Copyright (c) binaryscraping.co. All rights reserved.
// Licensed under the Apache 2.0 License. See LICENSE file in the project root for full license information.

import Foundation
import JSON

extension Logger {
  public struct Formatter {
    public var format: (Logger.Message) -> String

    public init(format: @escaping (Logger.Message) -> String) {
      self.format = format
    }
  }
}

let dateFormatter = ISO8601DateFormatter()

extension Logger.Formatter {
  public static let `default` = Logger.Formatter { msg in
    let dateString = dateFormatter.string(from: msg.date)

    let contextString: String
    if #available(iOS 11.0, macOS 10.13, watchOS 4.0, tvOS 11.0, *) {
      contextString = "\(msg.context.formatted(options: [.sortedKeys]))"
    } else {
      contextString = "\(msg.context.formatted())"
    }

    let fileName = msg.file
    return
      "\(dateString) [\(msg.level.description)][\(msg.system)] \(msg.msg) \(fileName).\(msg.function):\(msg.line) | \(contextString)"
  }
}
