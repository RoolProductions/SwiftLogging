/*
 *  SPDX-FileCopyrightText: 2026 Rool Production.
 *  SPDX-License-Identifier: EUPL-1.2
 */

// MARK: - LoggingLevel

/// The active logging threshold, ordered from most to least verbose.
///
/// Only messages at or above the configured level are printed. For example,
/// setting the level to `.warning` suppresses `.verbose`, `.debug`, and `.info`
/// output while still printing `.warning` and `.error` messages.
///
/// Use `.off` to silence all output entirely.
public enum LoggingLevel: Comparable, Sendable {
	
	/// Outputs the most detail. Useful for tracing execution flow.
	case verbose
	
	/// Outputs debug information useful during development.
	case debug
	
	/// Outputs general informational messages about app state.
	case info
	
	/// Outputs non-fatal issues that should be investigated.
	case warning
	
	/// Outputs error conditions that represent failures.
	case error
	
	/// Suppresses all log output.
	case off
	
	public static func < (lhs: LoggingLevel, rhs: LoggingLevel) -> Bool {
		return lhs.numericLevel < rhs.numericLevel
	}
	
	/// Numeric representation used for `Comparable` ordering.
	/// Higher values indicate greater verbosity.
	var numericLevel: Int {
		switch self {
			case .verbose: return 5
			case .debug:   return 4
			case .info:    return 3
			case .warning: return 2
			case .error:   return 1
			case .off:     return 0
		}
	}
}
