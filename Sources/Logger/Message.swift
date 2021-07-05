// Copyright (c) native.dev.br. All rights reserved.
// Licensed under the Apache 2.0 License. See LICENSE file in the project root for full license information.

import Foundation
import JSON

extension Logger {
  public struct Message: Codable {
    public let date: Date
    public let level: Logger.Level
    public let msg: String
    public let function: String
    public let file: String
    public let line: UInt
    public let context: JSON
    public let system: String
  }
}

extension Logger.Message {

  private enum CodingKeys: String, CodingKey {
    case date
    case level
    case msg
    case function
    case file
    case line
    case context
    case system
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let dateString = try container.decode(String.self, forKey: .date)
    date = dateFormatter.date(from: dateString) ?? Date()
    level = try container.decode(Logger.Level.self, forKey: .level)
    msg = try container.decode(String.self, forKey: .msg)
    function = try container.decode(String.self, forKey: .function)
    file = try container.decode(String.self, forKey: .file)
    line = try container.decode(UInt.self, forKey: .line)
    context = try container.decode(JSON.self, forKey: .context)
    system = try container.decode(String.self, forKey: .system)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(dateFormatter.string(from: date), forKey: .date)
    try container.encode(level, forKey: .level)
    try container.encode(msg, forKey: .msg)
    try container.encode(function, forKey: .function)
    try container.encode(file, forKey: .file)
    try container.encode(line, forKey: .line)
    try container.encode(context, forKey: .context)
    try container.encode(system, forKey: .system)
  }
}
