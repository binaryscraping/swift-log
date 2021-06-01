// Copyright (c) native.dev.br. All rights reserved.
// Licensed under the Apache 2.0 License. See LICENSE file in the project root for full license information.

import Foundation

extension Logger {
  public struct Destination {
    public var send: (Logger.Message, Logger.Formatter) -> Void

    public init(send: @escaping (Logger.Message, Logger.Formatter) -> Void) {
      self.send = send
    }
  }
}

extension Logger.Destination {
  public static let console = Self(
    send: { msg, formatter in
      #if DEBUG
        print(formatter.format(msg))
      #endif
    }
  )

  public static func file(atURL url: URL) throws -> Logger.Destination {
    let queue = DispatchQueue(label: "br.dev.native.logger.filedestination")

    if !FileManager.default.fileExists(atPath: url.path) {
      // TODO: maybe pass in some attributes?
      FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
    }

    return Logger.Destination { msg, formatter in
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
