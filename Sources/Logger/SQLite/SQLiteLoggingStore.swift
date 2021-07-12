// Copyright (c) native.dev.br. All rights reserved.
// Licensed under the Apache 2.0 License. See LICENSE file in the project root for full license information.

import Foundation
import JSON
import Sqlite

public final class SQLiteLoggingStore {

  private let db: Sqlite

  public init(path: String) throws {
    self.db = try Sqlite(path: path)

    try self.db.execute(
      """
      CREATE TABLE IF NOT EXISTS "logs" (
          "id" TEXT NOT NULL PRIMARY KEY,
          "date" DATETIME NOT NULL,
          "level" INTEGER NOT NULL,
          "message" TEXT NOT NULL,
          "function" TEXT NOT NULL,
          "file" TEXT NOT NULL,
          "line" INTEGER NOT NULL,
          "context" BLOB,
          "system" TEXT NOT NULL
      );
      """)
  }

  public var destination: Logger.Destination {
    Logger.Destination { [weak db] msg in
      do {
        let context = { () throws -> [UInt8]? in
          guard msg.context != .null else { return nil }
          let data = try JSONEncoder().encode(msg.context)
          return [UInt8](data)
        }

        try db?.run(
          """
             INSERT INTO "logs"
              ("id", "date", "level", "message", "function", "file", "line", "context", "system")
              VALUES
              (?, ?, ?, ?, ?, ?, ?, ?, ?);
          """,
          .text(UUID().uuidString),
          .text(dateFormatter.string(from: msg.date)),
          .integer(Int64(msg.level.rawValue)),
          .text(msg.msg),
          .text(msg.function),
          .text(msg.file),
          .integer(Int64(msg.line)),
          context().map(Sqlite.Datatype.blob) ?? .null,
          .text(msg.system)
        )
      } catch {
        debugPrint(error)
      }
    }
  }

  public func logs() -> [Logger.Message] {
    do {
      return try db.run(
        """
            SELECT
              "date", "level", "message", "function", "file", "line", "context", "system"
            FROM
              "logs";
        """
      )
      .map { row in
        Logger.Message(
          date: dateFormatter.date(from: row[0].textValue!)!,
          level: Logger.Level(rawValue: row[1].integerValue.map(Int.init)!)!,
          msg: row[2].textValue!,
          function: row[3].textValue!,
          file: row[4].textValue!,
          line: row[5].integerValue.map(UInt.init)!,
          context: row[6].isNull
            ? .null : try JSONDecoder().decode(JSON.self, from: Data(row[6].blobValue!)),
          system: row[7].textValue!
        )
      }
    } catch {
      debugPrint(error)
      return []
    }
  }
}
