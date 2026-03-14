/*
 *  SPDX-FileCopyrightText: 2026 Rool Production.
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

// MARK: - SwiftLogger

/// Namespace for global SwiftLogging configuration.
///
/// Set `SwiftLogger.level` once at app startup to enable logging. The level
/// defaults to `.off`, so no output is produced until explicitly configured.
///
/// ```swift
/// #if DEBUG
/// SwiftLogger.level = .verbose
/// #endif
/// ```
///
/// In unit tests, set the level before the test and reset it afterwards to
/// keep tests isolated:
///
/// ```swift
/// SwiftLogger.level = .verbose
/// defer { SwiftLogger.level = .off }
/// ```
public enum SwiftLogger {

	/// The active log level. Defaults to `.off`.
	///
	/// Set this explicitly at app startup, typically using `#if DEBUG` to
	/// vary the level per build configuration:
	///
	/// ```swift
	/// #if DEBUG
	/// SwiftLogger.level = .verbose
	/// #endif
	/// ```
	public nonisolated(unsafe) static var level: LoggingLevel = .off
}

// MARK: - Public logging functions

/// Logs a message at the verbose level.
///
/// Only produces output when `SwiftLogger.level` is `.verbose`.
/// Output is prefixed with 💤. Pass `showLocation: true` to append the
/// call-site location (`— function (file:line)`) to the output.
///
/// - Parameters:
///   - message: the message to log
///   - values: optional values to include in the log output
///   - file: the source file (auto-filled by the compiler)
///   - line: the line number (auto-filled by the compiler)
///   - function: the enclosing function (auto-filled by the compiler)
///   - showLocation: whether to include the file/line/function in the output;
///     defaults to `false`
public func logVerbose(
	_ message: String,
	_ values: Any...,
	file: String = #file,
	line: Int = #line,
	function: String = #function,
	showLocation: Bool = false
) {
	logVerbose(message, values, file: file, line: line, function: function, showLocation: showLocation)
}

/// Logs a message at the debug level.
///
/// Only produces output when `SwiftLogger.level` is `.verbose` or `.debug`.
/// Output is prefixed with 🐞. Pass `showLocation: true` to append the
/// call-site location (`— function (file:line)`) to the output.
///
/// - Parameters:
///   - message: the message to log
///   - values: optional values to include in the log output
///   - file: the source file (auto-filled by the compiler)
///   - line: the line number (auto-filled by the compiler)
///   - function: the enclosing function (auto-filled by the compiler)
///   - showLocation: whether to include the file/line/function in the output;
///     defaults to `false`
public func logDebug(
	_ message: String,
	_ values: Any...,
	file: String = #file,
	line: Int = #line,
	function: String = #function,
	showLocation: Bool = false
) {
	logDebug(message, values, file: file, line: line, function: function, showLocation: showLocation)
}

/// Logs a message at the info level.
///
/// Only produces output when `SwiftLogger.level` is `.verbose`, `.debug`,
/// or `.info`. Output is prefixed with 📋. Pass `showLocation: true` to append
/// the call-site location (`— function (file:line)`) to the output.
///
/// - Parameters:
///   - message: the message to log
///   - values: optional values to include in the log output
///   - file: the source file (auto-filled by the compiler)
///   - line: the line number (auto-filled by the compiler)
///   - function: the enclosing function (auto-filled by the compiler)
///   - showLocation: whether to include the file/line/function in the output;
///     defaults to `false`
public func logInfo(
	_ message: String,
	_ values: Any...,
	file: String = #file,
	line: Int = #line,
	function: String = #function,
	showLocation: Bool = false
) {
	logInfo(message, values, file: file, line: line, function: function, showLocation: showLocation)
}

/// Logs a message at the warning level.
///
/// Only produces output when `SwiftLogger.level` is `.verbose`, `.debug`,
/// `.info`, or `.warning`. Output is prefixed with ❗️. Pass `showLocation: true`
/// to append the call-site location (`— function (file:line)`) to the output.
///
/// - Parameters:
///   - message: the message to log
///   - values: optional values to include in the log output
///   - file: the source file (auto-filled by the compiler)
///   - line: the line number (auto-filled by the compiler)
///   - function: the enclosing function (auto-filled by the compiler)
///   - showLocation: whether to include the file/line/function in the output;
///     defaults to `false`
public func logWarning(
	_ message: String,
	_ values: Any...,
	file: String = #file,
	line: Int = #line,
	function: String = #function,
	showLocation: Bool = false
) {
	logWarning(message, values, file: file, line: line, function: function, showLocation: showLocation)
}

/// Logs a message at the error level.
///
/// Produces output at all `SwiftLogger.level` settings except `.off`.
/// Output is prefixed with 🔥. Pass `showLocation: true` to append the
/// call-site location (`— function (file:line)`) to the output.
///
/// - Parameters:
///   - message: the message to log
///   - values: optional values to include in the log output
///   - file: the source file (auto-filled by the compiler)
///   - line: the line number (auto-filled by the compiler)
///   - function: the enclosing function (auto-filled by the compiler)
///   - showLocation: whether to include the file/line/function in the output;
///     defaults to `false`
public func logError(
	_ message: String,
	_ values: Any...,
	file: String = #file,
	line: Int = #line,
	function: String = #function,
	showLocation: Bool = false
) {
	logError(message, values, file: file, line: line, function: function, showLocation: showLocation)
}

// MARK: - Internal overloads accepting [Any] to avoid variadic re-wrapping
//
// The public variadic functions collect their arguments into [Any] and pass
// them here. LogModifier.body also calls these directly so that the already-
// collected [Any] array is not re-wrapped into [[Any]] by a second variadic
// call. The file/line/function parameters are forwarded explicitly — not
// defaulted — so the captured call-site location is preserved.

func logVerbose(
	_ message: String, _ values: [Any],
	file: String, line: Int, function: String,
	showLocation: Bool
) {
	guard SwiftLogger.level >= .verbose else { return }
	log(icon: "💤", message: message, values,
		file: file, line: line, function: function, showLocation: showLocation)
}

func logDebug(
	_ message: String, _ values: [Any],
	file: String, line: Int, function: String,
	showLocation: Bool
) {
	guard SwiftLogger.level >= .debug else { return }
	log(icon: "🐞", message: message, values,
		file: file, line: line, function: function, showLocation: showLocation)
}

func logInfo(
	_ message: String, _ values: [Any],
	file: String, line: Int, function: String,
	showLocation: Bool
) {
	guard SwiftLogger.level >= .info else { return }
	log(icon: "📋", message: message, values,
		file: file, line: line, function: function, showLocation: showLocation)
}

func logWarning(
	_ message: String, _ values: [Any],
	file: String, line: Int, function: String,
	showLocation: Bool
) {
	guard SwiftLogger.level >= .warning else { return }
	log(icon: "❗️", message: message, values,
		file: file, line: line, function: function, showLocation: showLocation)
}

func logError(
	_ message: String, _ values: [Any],
	file: String, line: Int, function: String,
	showLocation: Bool
) {
	guard SwiftLogger.level >= .error else { return }
	log(icon: "🔥", message: message, values,
		file: file, line: line, function: function, showLocation: showLocation)
}

// MARK: - Output

/// Formats and prints a log line to stdout.
///
/// The output format is:
/// ```
/// <icon> <message>[: <values>] — <function> (<file>:<line>)
/// ```
///
/// - A single `[String: Any]` value is printed using its dictionary
///   description.
/// - Any other single value is interpolated inline after the message.
/// - Multiple values are printed as an array after the message.
/// - No values suffix is appended when `values` is empty.
private func log(
	icon: String,
	message: String,
	_ values: [Any],
	file: String,
	line: Int,
	function: String,
	showLocation: Bool
) {
	let context: String
	if showLocation {
		let filename = URL(fileURLWithPath: file).lastPathComponent
		context = " — \(function) (\(filename):\(line))"
	} else {
		context = ""
	}
	if values.count == 1, let dict = values[0] as? [String: Any] {
		print("\(icon) \(message): \(dict)\(context)")
	} else if values.count == 1 {
		print("\(icon) \(message): \(values[0])\(context)")
	} else if !values.isEmpty {
		print("\(icon) \(message): \(values)\(context)")
	} else {
		print("\(icon) \(message)\(context)")
	}
}
