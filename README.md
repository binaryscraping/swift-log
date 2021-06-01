# Logger
[![Test](https://github.com/nativedevbr/swift-log/actions/workflows/test.yml/badge.svg)](https://github.com/nativedevbr/swift-log/actions/workflows/test.yml)

Simple logging for simples needs.



### Crashlytics Example

```swift
import FirebaseCrashlytics

extension Logger.Destination {
  static let crashlytics = Logger.Destination { msg in
    let string = Logger.Formatter.default.format(msg)
    Crashlytics.crashlytics().log(string)
  }
}

Logger.main = Logger(system: "br.dev.native.logger", destinations: [.console(), .crashlytics])
```
