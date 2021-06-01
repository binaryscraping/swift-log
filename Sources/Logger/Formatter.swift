// Copyright (c) native.dev.br. All rights reserved.
// Licensed under the Apache 2.0 License. See LICENSE file in the project root for full license information.

import Foundation

extension Logger {
  public struct Formatter {
    public var format: (Logger.Message) -> String

    public init(format: @escaping (Logger.Message) -> String) {
      self.format = format
    }
  }
}

private let dateFormatter = ISO8601DateFormatter()

extension Logger.Formatter {
  public static let `default` = Logger.Formatter { msg in
    let dateString = dateFormatter.string(from: msg.date)
    let contextString = msg.context.map { "\($0)" } ?? "<nil>"
    let fileName = msg.file.split(separator: "/").last?.split(separator: ".").first ?? ""
    return
      "\(dateString) [\(msg.level.rawValue)][\(msg.system)] \(msg) \(fileName).\(msg.function):\(msg.line) | \(contextString)"
  }
}
