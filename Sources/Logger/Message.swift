// Copyright (c) native.dev.br. All rights reserved.
// Licensed under the Apache 2.0 License. See LICENSE file in the project root for full license information.

import Foundation

extension Logger {
  public struct Message {
    public let date: Date
    public let level: Logger.Level
    public let msg: String
    public let function: StaticString
    public let file: StaticString
    public let line: UInt
    public let context: Any?
    public let system: String
  }
}
