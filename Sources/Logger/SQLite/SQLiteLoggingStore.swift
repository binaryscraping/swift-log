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

  public func logs() throws -> [Logger.Message] {
    try db.run(
      """
          SELECT
            "date", "level", "message", "function", "file", "line", "context", "system"
          FROM
            "logs";
      """
    )
    .map { row in
      try Logger.Message(row: row)
    }
  }

  public enum Filter {
    case date(start: Date?, end: Date?)
    case level(Logger.Level)
    case message(String)
    case function(String)
    case file(String)
    case line(UInt)
    case system(String)

    indirect case or(Filter, Filter)

    var `where`: (String, [Sqlite.Datatype]) {
      switch self {
      case let .date(start?, end?):
        return (
          "\"date\" BETWEEN ? AND ?",
          [.text(dateFormatter.string(from: start)), .text(dateFormatter.string(from: end))]
        )

      case let .date(start?, nil):
        return ("\"date\" >= ?", [.text(dateFormatter.string(from: start))])

      case let .date(nil, end?):
        return ("\"date\" <= ?", [.text(dateFormatter.string(from: end))])

      case .date(nil, nil):
        return ("", [])

      case .file(let file):
        return ("\"file\" LIKE ?", [.text(file)])

      case .function(let function):
        return ("\"function\" LIKE ?", [.text(function)])

      case .level(let level):
        return ("\"level\" = ?", [.integer(Int64(level.rawValue))])

      case .line(let line):
        return ("\"line\" = ?", [.integer(Int64(line))])

      case .message(let message):
        return ("\"message\" LIKE ?", [.text(message)])

      case .system(let system):
        return ("\"system\" LIKE ?", [.text(system)])

      case let .or(lhs, rhs):
        let (lClause, lBindings) = lhs.where
        let (rClause, rBindings) = rhs.where
        return ("(\(lClause) OR \(rClause))", lBindings + rBindings)
      }
    }

  }

  public func logs(where filters: Filter...) throws -> [Logger.Message] {
    try self.logs(where: filters)
  }

  public func logs(where filters: [Filter]) throws -> [Logger.Message] {
    var clauses: [String] = []
    var bindings: [Sqlite.Datatype] = []

    for filter in filters {
      let (c, b) = filter.where
      clauses.append(c)
      bindings.append(contentsOf: b)
    }

    let whereClause = clauses.map { "(\($0))" }.joined(separator: " AND ")

    return try db.run(
      """
          SELECT
            "date", "level", "message", "function", "file", "line", "context", "system"
          FROM
            "logs"
          \(whereClause.isEmpty ? "" : "WHERE \(whereClause)");
      """,
      bindings
    )
    .map { row in
      try Logger.Message(row: row)
    }
  }
}

extension Logger.Message {
  init(row: [Sqlite.Datatype]) throws {
    self.init(
      date: row[0].textValue.flatMap { dateFormatter.date(from: $0) }!,
      level: row[1].integerValue.map(Int.init).flatMap(Logger.Level.init(rawValue:))!,
      msg: row[2].textValue!,
      function: row[3].textValue!,
      file: row[4].textValue!,
      line: row[5].integerValue.map(UInt.init)!,
      context: row[6].isNull
        ? .null
        : try JSONDecoder().decode(JSON.self, from: Data(row[6].blobValue!)),
      system: row[7].textValue!
    )
  }
}
