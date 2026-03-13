/*
 *  SPDX-FileCopyrightText: 2025 Rool Production.
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Testing
import SwiftUI
import ViewInspector
@testable import SwiftLogging

// MARK: - Stdout capture helper

/// Redirects stdout for the duration of `block` and returns whatever was printed.
private func captureStdout(_ block: () -> Void) -> String {
	let pipe = Pipe()
	let original = dup(STDOUT_FILENO)
	dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
	block()
	fflush(stdout)
	dup2(original, STDOUT_FILENO)
	close(original)
	pipe.fileHandleForWriting.closeFile()
	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	return String(data: data, encoding: .utf8) ?? ""
}

// MARK: - LoggingLevel tests

@Suite("LoggingLevel")
struct LoggingLevelTests {
	
	// MARK: Comparable ordering
	
	@Test("verbose is the highest level")
	func verboseIsHighest() {
		#expect(LoggingLevel.verbose > .debug)
		#expect(LoggingLevel.verbose > .info)
		#expect(LoggingLevel.verbose > .warning)
		#expect(LoggingLevel.verbose > .error)
		#expect(LoggingLevel.verbose > .off)
	}
	
	@Test("off is the lowest level")
	func offIsLowest() {
		#expect(LoggingLevel.off < .error)
		#expect(LoggingLevel.off < .warning)
		#expect(LoggingLevel.off < .info)
		#expect(LoggingLevel.off < .debug)
		#expect(LoggingLevel.off < .verbose)
	}
	
	@Test("levels compare correctly in sequence")
	func levelSequence() {
		#expect(LoggingLevel.error > .off)
		#expect(LoggingLevel.warning > .error)
		#expect(LoggingLevel.info > .warning)
		#expect(LoggingLevel.debug > .info)
		#expect(LoggingLevel.verbose > .debug)
	}
	
	@Test("same level equals itself")
	func sameLevelEquality() {
		#expect(LoggingLevel.verbose == .verbose)
		#expect(LoggingLevel.debug == .debug)
		#expect(LoggingLevel.info == .info)
		#expect(LoggingLevel.warning == .warning)
		#expect(LoggingLevel.error == .error)
		#expect(LoggingLevel.off == .off)
	}
	
	// MARK: Numeric level ordering

	@Test("numeric levels reflect verbosity order")
	func numericLevels() {
		#expect(LoggingLevel.verbose.numericLevel == 5)
		#expect(LoggingLevel.debug.numericLevel == 4)
		#expect(LoggingLevel.info.numericLevel == 3)
		#expect(LoggingLevel.warning.numericLevel == 2)
		#expect(LoggingLevel.error.numericLevel == 1)
		#expect(LoggingLevel.off.numericLevel == 0)
	}
}

// MARK: - Global state dependent tests
//
// These suites mutate SwiftLogger.level and capture stdout. They are nested
// inside a serialized parent suite to prevent parallel execution with each other.

@Suite("Global state tests", .serialized)
struct GlobalStateTests {
	
	@Suite("Log level gating", .serialized)
	struct LogLevelGatingTests {
		
		@Test("logVerbose produces output when level is verbose")
		func verboseOutputWhenLevelIsVerbose() {
			SwiftLogger.level = .verbose
			defer { SwiftLogger.level = .off }
			let output = captureStdout { logVerbose("gate test") }
			#expect(output.contains("gate test"))
		}
		
		@Test("logVerbose produces no output when level is debug")
		func verboseSuppressedWhenLevelIsDebug() {
			SwiftLogger.level = .debug
			defer { SwiftLogger.level = .off }
			let output = captureStdout { logVerbose("gate test") }
			#expect(output.isEmpty)
		}
		
		@Test("logDebug produces no output when level is info")
		func debugSuppressedWhenLevelIsInfo() {
			SwiftLogger.level = .info
			defer { SwiftLogger.level = .off }
			let output = captureStdout { logDebug("gate test") }
			#expect(output.isEmpty)
		}
		
		@Test("logInfo produces output when level is info")
		func infoOutputWhenLevelIsInfo() {
			SwiftLogger.level = .info
			defer { SwiftLogger.level = .off }
			let output = captureStdout { logInfo("gate test") }
			#expect(output.contains("gate test"))
		}
		
		@Test("logWarning produces no output when level is error")
		func warningSuppressedWhenLevelIsError() {
			SwiftLogger.level = .error
			defer { SwiftLogger.level = .off }
			let output = captureStdout { logWarning("gate test") }
			#expect(output.isEmpty)
		}
		
		@Test("logWarning produces output when level is warning")
		func warningOutputWhenLevelIsWarning() {
			SwiftLogger.level = .warning
			defer { SwiftLogger.level = .off }
			let output = captureStdout { logWarning("gate test") }
			#expect(output.contains("gate test"))
		}
		
		@Test("logError produces no output when level is off")
		func errorSuppressedWhenLevelIsOff() {
			SwiftLogger.level = .off
			let output = captureStdout { logError("gate test") }
			#expect(output.isEmpty)
		}
		
		@Test("logError produces output when level is error")
		func errorOutputWhenLevelIsError() {
			SwiftLogger.level = .error
			defer { SwiftLogger.level = .off }
			let output = captureStdout { logError("gate test") }
			#expect(output.contains("gate test"))
		}
	}
	
	// MARK: - Output formatting tests
	
	@Suite("Log output formatting", .serialized)
	struct LogOutputFormattingTests {
		
		@Test("no values prints message only")
		func noValues() {
			SwiftLogger.level = .verbose
			defer { SwiftLogger.level = .off }
			let output = captureStdout { logVerbose("hello") }
			// Icon and message appear before the context separator, with no colon between them
			#expect(output.contains("💤 hello —"))
		}
		
		@Test("single value is printed inline after message")
		func singleValue() {
			SwiftLogger.level = .verbose
			defer { SwiftLogger.level = .off }
			let output = captureStdout { logVerbose("count", 42) }
			#expect(output.contains("💤 count: 42"))
		}
		
		@Test("single dictionary value is printed with dictionary format")
		func singleDictionaryValue() {
			SwiftLogger.level = .verbose
			defer { SwiftLogger.level = .off }
			let output = captureStdout { logVerbose("dict", ["key": "value"]) }
			#expect(output.contains("💤 dict:"))
			#expect(output.contains("key"))
			#expect(output.contains("value"))
		}
		
		@Test("multiple values are printed as array after message")
		func multipleValues() {
			SwiftLogger.level = .verbose
			defer { SwiftLogger.level = .off }
			let output = captureStdout { logVerbose("items", "a", "b") }
			#expect(output.contains("💤 items:"))
			#expect(output.contains("a"))
			#expect(output.contains("b"))
		}
		
		@Test("correct icon is used for each level")
		func icons() {
			SwiftLogger.level = .verbose
			defer { SwiftLogger.level = .off }
			#expect(captureStdout { logVerbose("m") }.hasPrefix("💤"))
			#expect(captureStdout { logDebug("m") }.hasPrefix("🐞"))
			#expect(captureStdout { logInfo("m") }.hasPrefix("📋"))
			#expect(captureStdout { logWarning("m") }.hasPrefix("❗️"))
			#expect(captureStdout { logError("m") }.hasPrefix("🔥"))
		}
		
		@Test("output includes call-site file, line, and function")
		func callSiteContext() {
			SwiftLogger.level = .verbose
			defer { SwiftLogger.level = .off }
			let output = captureStdout { logVerbose("ctx") }
			#expect(output.contains("SwiftLoggingTests.swift"))
			#expect(output.contains("callSiteContext()"))
			#expect(output.contains("—"))
		}
	} // LogOutputFormattingTests

	// MARK: Modifier output with values

	@Suite("LogModifier output", .serialized)
	@MainActor
	struct LogModifierOutputTests {

		@Test("modifier prints values when they are passed through onAppear")
		func modifierWithValues() throws {
			SwiftLogger.level = .verbose
			defer { SwiftLogger.level = .off }
			let sut = Text("Values").modifier(LogModifier("msg", .verbose, [42, "extra"]))
			let content = try sut.inspect().text().modifier(LogModifier.self).viewModifierContent()
			let output = captureStdout { try? content.callOnAppear() }
			#expect(output.contains("msg"))
			#expect(output.contains("42"))
			#expect(output.contains("extra"))
		}
	} // LogModifierOutputTests
} // GlobalStateTests

// MARK: - LogModifier tests

@Suite("LogModifier")
@MainActor
struct LogModifierTests {
	
	// MARK: Modifier presence
	
	@Test("logVerbose applies a LogModifier to the view")
	func logVerboseAppliesLogModifier() throws {
		let sut = Text("Hello").logVerbose("verbose message")
		#expect(throws: Never.self) {
			try sut.inspect().text().modifier(LogModifier.self)
		}
	}
	
	@Test("logDebug applies a LogModifier to the view")
	func logDebugAppliesLogModifier() throws {
		let sut = Text("Hello").logDebug("debug message")
		#expect(throws: Never.self) {
			try sut.inspect().text().modifier(LogModifier.self)
		}
	}
	
	@Test("logInfo applies a LogModifier to the view")
	func logInfoAppliesLogModifier() throws {
		let sut = Text("Hello").logInfo("info message")
		#expect(throws: Never.self) {
			try sut.inspect().text().modifier(LogModifier.self)
		}
	}
	
	@Test("logWarning applies a LogModifier to the view")
	func logWarningAppliesLogModifier() throws {
		let sut = Text("Hello").logWarning("warning message")
		#expect(throws: Never.self) {
			try sut.inspect().text().modifier(LogModifier.self)
		}
	}
	
	@Test("logError applies a LogModifier to the view")
	func logErrorAppliesLogModifier() throws {
		let sut = Text("Hello").logError("error message")
		#expect(throws: Never.self) {
			try sut.inspect().text().modifier(LogModifier.self)
		}
	}
	
	// MARK: Content pass-through
	
	@Test("modifier body passes content through unchanged")
	func modifierBodyPassesContentThrough() throws {
		let sut = Text("Pass-through").modifier(LogModifier("test", .verbose))
		#expect(throws: Never.self) {
			try sut.inspect().text().modifier(LogModifier.self).viewModifierContent()
		}
	}
	
	// MARK: onAppear fires for all log levels
	
	@Test("onAppear fires for all LoggingLevel cases", arguments: [
		LoggingLevel.verbose,
		LoggingLevel.debug,
		LoggingLevel.info,
		LoggingLevel.warning,
		LoggingLevel.error,
		LoggingLevel.off
	])
	func onAppearFiresForAllLevels(level: LoggingLevel) throws {
		let sut = Text("Appear").modifier(LogModifier("test", level))
		let content = try sut.inspect().text().modifier(LogModifier.self).viewModifierContent()
		try content.callOnAppear()
	}

	@Test("modifier with .off level produces no output")
	func modifierWithOffLevelProducesNoOutput() throws {
		let sut = Text("Off").modifier(LogModifier("test", .off))
		let content = try sut.inspect().text().modifier(LogModifier.self).viewModifierContent()
		let output = captureStdout { try? content.callOnAppear() }
		#expect(output.isEmpty)
	}
	
	// MARK: Chaining
	
	@Test("multiple log modifiers can be chained")
	func chainingAttachesMultipleModifiers() throws {
		let sut = Text("Chained")
			.logVerbose("step 1")
			.logDebug("step 2")
		#expect(throws: Never.self) {
			try sut.inspect().modifier(LogModifier.self)
		}
	}
}
