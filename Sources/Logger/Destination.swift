// Copyright (c) native.dev.br. All rights reserved.
// Licensed under the Apache 2.0 License. See LICENSE file in the project root for full license information.

import Foundation
import SQLite

extension Logger {
  public struct Destination {
    public var send: (Logger.Message) -> Void

    public init(send: @escaping (Logger.Message) -> Void) {
      self.send = send
    }
  }
}

extension Logger.Destination {
  public static func console(using formatter: Logger.Formatter = .default) -> Logger.Destination {
    Logger.Destination(
      send: { msg in
        #if DEBUG
          print(formatter.format(msg))
        #endif
      }
    )
  }

  public static func file(atURL url: URL, using formatter: Logger.Formatter = .default) throws
    -> Logger.Destination
  {
    let queue = DispatchQueue(label: "br.dev.native.logger.filedestination")

    if !FileManager.default.fileExists(atPath: url.path) {
      // TODO: maybe pass in some attributes?
      FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
    }

    return Logger.Destination { msg in
      queue.sync {
        do {
          let handle = try FileHandle(forWritingTo: url)
          handle.seekToEndOfFile()
          handle.write(Data("\(formatter.format(msg))\n".utf8))
          handle.closeFile()
        } catch {
          print(error)
        }
      }
    }
  }
}

extension Logger.Destination {

  public static func sqlite(atURL url: URL) throws -> Logger.Destination {
    let db = try Connection(url.path)

    #if DEBUG
      db.trace { print($0) }
    #endif

    let logs = Table("logs")
    let id = Expression<String>("id")
    let date = Expression<Date>("date")
    let level = Expression<Int>("level")
    let message = Expression<String>("message")
    let function = Expression<String>("function")
    let file = Expression<String>("file")
    let line = Expression<Int>("line")
    let context = Expression<Blob?>("context")
    let system = Expression<String>("system")

    try db.run(
      logs.create(ifNotExists: true) { t in
        t.column(id, primaryKey: true)
        t.column(date)
        t.column(level)
        t.column(message)
        t.column(function)
        t.column(file)
        t.column(line)
        t.column(context)
        t.column(system)
      })

    return Logger.Destination { msg in
      do {
        let blob: () throws -> Blob? = {
          guard msg.context != .null else { return nil }
          let data = try JSONEncoder().encode(msg.context)
          let bytes = [UInt8](data)
          return Blob(bytes: bytes)
        }

        try db.run(
          logs.insert(
            id <- UUID().uuidString,
            date <- msg.date,
            level <- msg.level.rawValue,
            message <- msg.msg,
            function <- msg.function,
            file <- msg.file,
            line <- Int(msg.line),
            context <- blob(),
            system <- msg.system
          )
        )
      } catch {
        debugPrint(error)
      }
    }
  }
}
