# Logger
[![Test](https://github.com/nativedevbr/swift-log/actions/workflows/test.yml/badge.svg)](https://github.com/nativedevbr/swift-log/actions/workflows/test.yml)

Simple logging for simples needs.



### Crashlytics Example

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
Logger.main = Logger(system: "br.dev.native.logger", destinations: [.console(), .crashlytics])
```
