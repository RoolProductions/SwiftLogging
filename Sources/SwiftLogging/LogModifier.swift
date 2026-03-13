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
	func logVerbose(
		_ message: String,
		_ values: Any...,
		file: String = #file,
		line: Int = #line,
		function: String = #function
	) -> some View {
		modifier(LogModifier(
			message, .verbose, values,
			file: file, line: line, function: function
		))
	}
	
	/// Logs a debug-level message when the view appears.
	/// - Parameters:
	///   - message: the message to log
	///   - values: optional values to include in the log output
	///   - file: the source file (auto-filled by the compiler)
	///   - line: the line number (auto-filled by the compiler)
	///   - function: the enclosing function (auto-filled by the compiler)
	func logDebug(
		_ message: String,
		_ values: Any...,
		file: String = #file,
		line: Int = #line,
		function: String = #function
	) -> some View {
		modifier(LogModifier(
			message, .debug, values,
			file: file, line: line, function: function
		))
	}
	
	/// Logs an info-level message when the view appears.
	/// - Parameters:
	///   - message: the message to log
	///   - values: optional values to include in the log output
	///   - file: the source file (auto-filled by the compiler)
	///   - line: the line number (auto-filled by the compiler)
	///   - function: the enclosing function (auto-filled by the compiler)
	func logInfo(
		_ message: String,
		_ values: Any...,
		file: String = #file,
		line: Int = #line,
		function: String = #function
	) -> some View {
		modifier(LogModifier(
			message, .info, values,
			file: file, line: line, function: function
		))
	}
	
	/// Logs a warning-level message when the view appears.
	/// - Parameters:
	///   - message: the message to log
	///   - values: optional values to include in the log output
	///   - file: the source file (auto-filled by the compiler)
	///   - line: the line number (auto-filled by the compiler)
	///   - function: the enclosing function (auto-filled by the compiler)
	func logWarning(
		_ message: String,
		_ values: Any...,
		file: String = #file,
		line: Int = #line,
		function: String = #function
	) -> some View {
		modifier(LogModifier(
			message, .warning, values,
			file: file, line: line, function: function
		))
	}
	
	/// Logs an error-level message when the view appears.
	/// - Parameters:
	///   - message: the message to log
	///   - values: optional values to include in the log output
	///   - file: the source file (auto-filled by the compiler)
	///   - line: the line number (auto-filled by the compiler)
	///   - function: the enclosing function (auto-filled by the compiler)
	func logError(
		_ message: String,
		_ values: Any...,
		file: String = #file,
		line: Int = #line,
		function: String = #function
	) -> some View {
		modifier(LogModifier(
			message, .error, values,
			file: file, line: line, function: function
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
	
	/// Creates a log modifier that will log at the given level when the
	/// view appears.
	/// - Parameters:
	///   - message: the message to log
	///   - logLevel: the severity level for the log message
	///   - values: optional values to include in the log output
	///   - file: the source file (auto-filled by the compiler)
	///   - line: the line number (auto-filled by the compiler)
	///   - function: the enclosing function (auto-filled by the compiler)
	init(
		_ message: String,
		_ logLevel: LoggingLevel,
		_ values: [Any] = [],
		file: String = #file,
		line: Int = #line,
		function: String = #function
	) {
		self.message = message
		self.logLevel = logLevel
		self.values = values
		self.file = file
		self.line = line
		self.function = function
	}
	
	public func body(content: Self.Content) -> some View {
		content
			.onAppear {
				switch logLevel {
					case .verbose:
						logVerbose(message, values,
								   file: file, line: line, function: function)
					case .debug:
						logDebug(message, values,
								 file: file, line: line, function: function)
					case .info:
						logInfo(message, values,
								file: file, line: line, function: function)
					case .warning:
						logWarning(message, values,
								   file: file, line: line, function: function)
					case .error:
						logError(message, values,
								 file: file, line: line, function: function)
					case .off:
						break
				}
			}
	}
}
