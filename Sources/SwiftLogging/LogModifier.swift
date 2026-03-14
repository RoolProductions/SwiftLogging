/*
 *  SPDX-FileCopyrightText: 2026 Rool Production.
 *  SPDX-License-Identifier: EUPL-1.2
 */

import SwiftUI

public extension View {
	
	/// Logs a verbose-level message when the view appears.
	/// - Parameters:
	///   - message: the message to log
	///   - values: optional values to include in the log output
	///   - file: the source file (auto-filled by the compiler)
	///   - line: the line number (auto-filled by the compiler)
	///   - function: the enclosing function (auto-filled by the compiler)
	///   - showLocation: whether to include the file/line/function in the output;
	///     defaults to `false`
	func logVerbose(
		_ message: String,
		_ values: Any...,
		file: String = #file,
		line: Int = #line,
		function: String = #function,
		showLocation: Bool = false
	) -> some View {
		modifier(LogModifier(
			message, .verbose, values,
			file: file, line: line, function: function,
			showLocation: showLocation
		))
	}
	
	/// Logs a debug-level message when the view appears.
	/// - Parameters:
	///   - message: the message to log
	///   - values: optional values to include in the log output
	///   - file: the source file (auto-filled by the compiler)
	///   - line: the line number (auto-filled by the compiler)
	///   - function: the enclosing function (auto-filled by the compiler)
	///   - showLocation: whether to include the file/line/function in the output;
	///     defaults to `false`
	func logDebug(
		_ message: String,
		_ values: Any...,
		file: String = #file,
		line: Int = #line,
		function: String = #function,
		showLocation: Bool = false
	) -> some View {
		modifier(LogModifier(
			message, .debug, values,
			file: file, line: line, function: function,
			showLocation: showLocation
		))
	}
	
	/// Logs an info-level message when the view appears.
	/// - Parameters:
	///   - message: the message to log
	///   - values: optional values to include in the log output
	///   - file: the source file (auto-filled by the compiler)
	///   - line: the line number (auto-filled by the compiler)
	///   - function: the enclosing function (auto-filled by the compiler)
	///   - showLocation: whether to include the file/line/function in the output;
	///     defaults to `false`
	func logInfo(
		_ message: String,
		_ values: Any...,
		file: String = #file,
		line: Int = #line,
		function: String = #function,
		showLocation: Bool = false
	) -> some View {
		modifier(LogModifier(
			message, .info, values,
			file: file, line: line, function: function,
			showLocation: showLocation
		))
	}
	
	/// Logs a warning-level message when the view appears.
	/// - Parameters:
	///   - message: the message to log
	///   - values: optional values to include in the log output
	///   - file: the source file (auto-filled by the compiler)
	///   - line: the line number (auto-filled by the compiler)
	///   - function: the enclosing function (auto-filled by the compiler)
	///   - showLocation: whether to include the file/line/function in the output;
	///     defaults to `false`
	func logWarning(
		_ message: String,
		_ values: Any...,
		file: String = #file,
		line: Int = #line,
		function: String = #function,
		showLocation: Bool = false
	) -> some View {
		modifier(LogModifier(
			message, .warning, values,
			file: file, line: line, function: function,
			showLocation: showLocation
		))
	}
	
	/// Logs an error-level message when the view appears.
	/// - Parameters:
	///   - message: the message to log
	///   - values: optional values to include in the log output
	///   - file: the source file (auto-filled by the compiler)
	///   - line: the line number (auto-filled by the compiler)
	///   - function: the enclosing function (auto-filled by the compiler)
	///   - showLocation: whether to include the file/line/function in the output;
	///     defaults to `false`
	func logError(
		_ message: String,
		_ values: Any...,
		file: String = #file,
		line: Int = #line,
		function: String = #function,
		showLocation: Bool = false
	) -> some View {
		modifier(LogModifier(
			message, .error, values,
			file: file, line: line, function: function,
			showLocation: showLocation
		))
	}
}

/// A view modifier that logs a message when the modified view appears.
public struct LogModifier: ViewModifier {
	
	private let message: String
	private let logLevel: LoggingLevel
	private let values: [Any]
	private let file: String
	private let line: Int
	private let function: String
	private let showLocation: Bool
	
	/// Creates a log modifier that will log at the given level when the
	/// view appears.
	/// - Parameters:
	///   - message: the message to log
	///   - logLevel: the severity level for the log message
	///   - values: optional values to include in the log output
	///   - file: the source file (auto-filled by the compiler)
	///   - line: the line number (auto-filled by the compiler)
	///   - function: the enclosing function (auto-filled by the compiler)
	///   - showLocation: whether to include the file/line/function in the output;
	///     defaults to `false`
	init(
		_ message: String,
		_ logLevel: LoggingLevel,
		_ values: [Any] = [],
		file: String = #file,
		line: Int = #line,
		function: String = #function,
		showLocation: Bool = false
	) {
		self.message = message
		self.logLevel = logLevel
		self.values = values
		self.file = file
		self.line = line
		self.function = function
		self.showLocation = showLocation
	}
	
	public func body(content: Self.Content) -> some View {
		content
			.onAppear {
				switch logLevel {
					case .verbose:
						logVerbose(message, values,
								   file: file, line: line, function: function,
								   showLocation: showLocation)
					case .debug:
						logDebug(message, values,
								 file: file, line: line, function: function,
								 showLocation: showLocation)
					case .info:
						logInfo(message, values,
								file: file, line: line, function: function,
								showLocation: showLocation)
					case .warning:
						logWarning(message, values,
								   file: file, line: line, function: function,
								   showLocation: showLocation)
					case .error:
						logError(message, values,
								 file: file, line: line, function: function,
								 showLocation: showLocation)
					case .off:
						break
				}
			}
	}
}
