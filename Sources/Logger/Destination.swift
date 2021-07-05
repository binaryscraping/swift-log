// Copyright (c) native.dev.br. All rights reserved.
// Licensed under the Apache 2.0 License. See LICENSE file in the project root for full license information.

import Foundation
import Sqlite

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

//extension Logger.Destination {
//
//  public static func sqlite() throws -> Logger.Destination {
//    let queue = DispatchQueue(label: "br.dev.native.logger.sqlite")
//    let sqlite = try Sqlite(path: ":memory")
//
//    try queue.sync {
//      try sqlite.execute(
//        """
//            CREATE TABLE IF NOT EXISTS "logs" (
//                "id" TEXT PRIMARY KEY,
//                "level" TEXT NOT NULL,
//                "message" TEXT NOT NULL,
//                "function" TEXT NOT NULL,
//                "file" TEXT NOT NULL,
//                "line" INTEGER NOT NULL,
//                "context" BLOB NOT NULL,
//                "system" TEXT NOT NULL
//            );
//        """)
//    }
//
//    return Logger.Destination { msg in
//      queue.async {
//        do {
//          let contextBlob = try JSONEncoder().encode(msg.context)
//          try sqlite.run(
//            """
//                INSERT INTO "logs"
//                    ("id", "level", "message", "function", "file", "line", "context", "system")
//                VALUES
//                    (?, ?, ?, ?, ?, ?, ?, ?);
//            """,
//            .text(UUID().uuidString),
//            .text(msg.level.rawValue),
//            .text(msg.msg),
//            .text(msg.function.description),
//            .text(msg.file.description),
//            .integer(Int64(msg.line)),
//            .blob([UInt8](contextBlob)),
//            .text(msg.system)
//          )
//        } catch {
//          debugPrint(error)
//        }
//      }
//    }
//  }
//}
