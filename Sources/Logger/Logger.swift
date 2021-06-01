// Copyright (c) native.dev.br. All rights reserved.
// Licensed under the Apache 2.0 License. See LICENSE file in the project root for full license information.

import Foundation

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

  public enum Level: String, Encodable {
    case verbose = "VERBOSE"
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
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
    function: String = #function,
    file: String = #fileID,
    line: Int = #line,
    context: Any? = nil
  ) {
    let message = Message(
      date: Date(),
      level: level,
      msg: msg(),
      function: function,
      file: file,
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
    function: String = #function,
    file: String = #fileID,
    line: Int = #line,
    context: Any? = nil
  ) {
    log(level: .verbose, msg: msg(), function: function, file: file, line: line, context: context)
  }

  public func debug(
    _ msg: @autoclosure () -> String,
    function: String = #function,
    file: String = #fileID,
    line: Int = #line,
    context: Any? = nil
  ) {
    log(level: .debug, msg: msg(), function: function, file: file, line: line, context: context)
  }

  public func info(
    _ msg: @autoclosure () -> String,
    function: String = #function,
    file: String = #fileID,
    line: Int = #line,
    context: Any? = nil
  ) {
    log(level: .info, msg: msg(), function: function, file: file, line: line, context: context)
  }

  public func warning(
    _ msg: @autoclosure () -> String,
    function: String = #function,
    file: String = #fileID,
    line: Int = #line,
    context: Any? = nil
  ) {
    log(level: .warning, msg: msg(), function: function, file: file, line: line, context: context)
  }

  public func error(
    _ msg: @autoclosure () -> String,
    function: String = #function,
    file: String = #fileID,
    line: Int = #line,
    context: Any? = nil
  ) {
    log(level: .error, msg: msg(), function: function, file: file, line: line, context: context)
  }
}
