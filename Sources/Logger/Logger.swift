// Copyright (c) binaryscraping.co. All rights reserved.
// Licensed under the MIT License. See LICENSE file in the project root for full license information.

import Foundation
import JSON

public struct Logger {
  public static var main: Logger {
    get {
      guard let _main = _main else {
        preconditionFailure("Logger.main not defined, please define a main logger before using it.")
      }

      return _main
    }

    set {
      _main = newValue
    }
  }

  private static var _main: Logger?

  public let system: String
  public let destinations: [Destination]
  public let formatter: Formatter

  public enum Level: Int, Codable {
    case verbose
    case debug
    case info
    case warning
    case error

    public var description: String {
      switch self {
      case .verbose: return "VERBOSE"
      case .debug: return "DEBUG"
      case .info: return "INFO"
      case .warning: return "WARNING"
      case .error: return "ERROR"
      }
    }
  }

  public init(
    system: String,
    destinations: [Destination],
    formatter: Formatter = .default
  ) {
    self.system = system
    self.destinations = destinations
    self.formatter = formatter
  }
}

extension Logger {
  public func log(
    level: Level,
    msg: @autoclosure () -> String,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    context: JSON = .null
  ) {
    let message = Message(
      date: Date(),
      level: level,
      msg: msg(),
      function: "\(function)",
      file: "\(file)",
      line: line,
      context: context,
      system: system
    )

    destinations.forEach {
      $0.send(message)
    }
  }

  public func verbose(
    _ msg: @autoclosure () -> String,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    context: JSON = .null
  ) {
    log(level: .verbose, msg: msg(), function: function, file: file, line: line, context: context)
  }

  public func debug(
    _ msg: @autoclosure () -> String,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    context: JSON = .null
  ) {
    log(level: .debug, msg: msg(), function: function, file: file, line: line, context: context)
  }

  public func info(
    _ msg: @autoclosure () -> String,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    context: JSON = .null
  ) {
    log(level: .info, msg: msg(), function: function, file: file, line: line, context: context)
  }

  public func warning(
    _ msg: @autoclosure () -> String,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    context: JSON = .null
  ) {
    log(level: .warning, msg: msg(), function: function, file: file, line: line, context: context)
  }

  public func error(
    _ msg: @autoclosure () -> String,
    function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line,
    context: JSON = .null
  ) {
    log(level: .error, msg: msg(), function: function, file: file, line: line, context: context)
  }
}
