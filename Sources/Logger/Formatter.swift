// Copyright (c) native.dev.br. All rights reserved.
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

private let dateFormatter = ISO8601DateFormatter()

extension Logger.Formatter {
  public static let `default` = Logger.Formatter { msg in
    let dateString = dateFormatter.string(from: msg.date)
    let contextString = "\(msg.context)"
    let fileName = msg.file
    return
      "\(dateString) [\(msg.level.rawValue)][\(msg.system)] \(msg.msg) \(fileName).\(msg.function):\(msg.line) | \(contextString)"
  }
}

extension JSON: CustomStringConvertible {
  public var description: String {
    switch self {
    case .array(let array): return array.description
    case .bool(let bool): return bool.description
    case .null: return "nil"
    case .number(let number): return number.description
    case .object(let dict): return dict.description
    case .string(let string): return string
    }
  }
}
