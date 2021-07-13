# Logger
[![Test](https://github.com/nativedevbr/swift-log/actions/workflows/test.yml/badge.svg)](https://github.com/nativedevbr/swift-log/actions/workflows/test.yml)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnativedevbr%2Fswift-log%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/nativedevbr/swift-log)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnativedevbr%2Fswift-log%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/nativedevbr/swift-log)

Simple logging for simples needs.

## Getting Started

Declare your dependency in your `Package.swift` file.

**Attention: This library is not stable and any update can introduce a BREAKING CHANGE.**

```swift
.package(name: "Logger", url: "https://github.com/nativedevbr/swift-log.git", from: "0.1.0"),
```
 and add it to your application target.
 
 ```swift
 .target(name: "BestExampleApp", dependencies: ["Logger"]),
 ```

Now, let's learn how to use it.

```swift
// Import the logger package.
import Logger

// Create a logger instance, the system is a string that identifies this logging instance.
// It's recommended to use an inverse domain like your bundle identifier.
// This logging implementation is based on destinations, each destination represent a place where
// the log messagens will be sent.
let logger = Logger(system: "br.dev.native.best-example-app", destinations: [.console(), .file(url: URL(...)])

// Then, just call the available methods on the logger instance, there is one method for each
// logging level. [verbose, debug, info, warning and error].
logger.info("Hello World!")

// There's support for adding additional context to a log message.
logger.error("something is not working", context: ["user_id": "deadbeef"])
```

If you prefer, there's possibility for defining a shared logger instance through `Logger.main`.

```swift
Logger.main = Logger(system: "br.dev.native.best-example-app", destinations: [.console(), .file(url: URL(...)])
```

If `Logger.main` is used before being initialized the app will crash. 

### Destinations

This package provides three destinations out of the box, the `console`, `file` and `sqlite`.

The `console` destination sends the log messages to the console and it's `debug` only, so no logs are sent on `release` builds.

The `file` destination writes logs messages to a local file that the user must provide.

And the `sqlite` destination writes logs to a sqlite database, this is the most powerful destination as you can aggregate and query for logs.

Boths destinations accepts a `Formatter` parameter to customize the formatting logic of the message, there's a default implementation.

#### SQLite Destination

There is a default implementaiton for a SQLite destination that supports filtering log messages.

```swift
// Initialize a new SQLiteLoggingStore passing the database path.
// It's important to keep a single instance of a SQLiteLoggingStore through the whole life cycle.
let store = try SQLiteLoggingStore(path: "path/to/db.sqlite")

// Init a Logger instance by passing the store's destination
let logger = Logger(
  system: "br.dev.native.logger.tests",
  destinations: [store.destination]
)

// Use the logger
logger.info("info message")

// And then query the log messages by using method `logs(where:)`.
let logs = try store.logs(
  where: .or(.level(.info), .level(.error)), .file("%Tests.swift"))
  
// The above filter is transformed into a SQL `where` clause and stands for:
// 'Fetch all log messages that has a level error or info and has happened on files that ends with "Tests.swift"'.
// Example: 'WHERE ("level" = 2 OR "level" = 4) AND ("file" LIKE "%Tests.swift")'
```

For available filters, take a look at the [Filter `enum`](https://github.com/nativedevbr/swift-log/blob/main/Sources/Logger/SQLite/SQLiteLoggingStore.swift#L77).

#### Custom destinations

This destination approach makes very easy to add new ones, like this example of a destination that sends the log messages to `Crashlytics`.

```swift
import FirebaseCrashlytics

extension Logger.Destination {
  static let crashlytics = Logger.Destination { msg in
    // You can use the default formatter for generating a string, 
    // or implement your own formatting logic.
    let string = Logger.Formatter.default.format(msg)
    Crashlytics.crashlytics().log(string)
  }
}

// Then to use the new destination, simply init a logger passing the `crashlytics` destination.
Logger.main = Logger(system: "br.dev.native.best-example-app", destinations: [.console(), .crashlytics])
```

## Contributing

Pull requests are welcome.

Please make sure to update tests as appropriate.

## License
[Apache 2.0](/LICENSE)
