// Copyright (c) binaryscraping.co. All rights reserved.
// Licensed under the Apache 2.0 License. See LICENSE file in the project root for full license information.

import Foundation

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
    let queue = DispatchQueue(label: "co.binaryscraping.logger.filedestination")

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
