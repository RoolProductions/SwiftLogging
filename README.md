# SwiftLogging

A simple logging tool

## Setup

Set the log level once at app startup, typically in your `@main` entry point:

```swift
import SwiftLogging

#if DEBUG
SwiftLogger.level = .verbose
#endif
```

The level defaults to `.off`, so no output is produced until explicitly configured. Available levels in order of decreasing verbosity: `.verbose`, `.debug`, `.info`, `.warning`, `.error`, `.off`.

## Usage

Each log function produces a line prefixed with an icon, followed by the message and call-site location (function name, file, and line number):

```
💤 My message — myFunction() (MyView.swift:42)
```

```swift
import SwiftLogging

logVerbose("This is awesome!") // 💤
logDebug("This is awesome!")   // 🐞
logInfo("This is awesome!")    // 📋
logWarning("This is awesome!") // ❗️
logError("This is awesome!")   // 🔥
```

The log functions also accept additional values that are printed inline with the message:

```swift
import SwiftLogging

let value = ["foo"]
logDebug("The value is", value)
// 🐞 The value is: ["foo"] — ...

let arrayValues: [String] = ["foo", "bar"]
logDebug("The values are", arrayValues)
// 🐞 The values are: ["foo", "bar"] — ...

let dictValues = ["foo": "bar", "bar": "baz"]
logDebug("The values are", dictValues)
// 🐞 The values are: ["bar": "baz", "foo": "bar"] — ...
```

## SwiftUI View Modifier

You can also log directly from SwiftUI views using the view modifier extensions. The message is logged when the view appears.

```swift
import SwiftLogging

Text("Hello")
    .logDebug("View appeared")
    .logInfo("With a value", 42)
```

## License

This repository follows the [REUSE Specification v3.0](https://reuse.software/spec/). Please see [REUSE.toml](./REUSE.toml) and the individual `*.license` files for copyright and license information.
