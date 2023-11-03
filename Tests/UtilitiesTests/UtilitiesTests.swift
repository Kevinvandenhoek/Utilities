import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(UtilitiesMacros)
import UtilitiesMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "URL": URLMacro.self
]
#endif

final class UtilitiesTests: XCTestCase {
    
    func testURLMacro() throws {
        assertMacroExpansion(
        """
        #URL("https://pokeapi.co/api")
        """,
        expandedSource: """
        URL(string: "https://pokeapi.co/api")!
        """,
        macros: testMacros
        )
    }
    
    func testMacro() throws {
        #if canImport(UtilitiesMacros)
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(UtilitiesMacros)
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
