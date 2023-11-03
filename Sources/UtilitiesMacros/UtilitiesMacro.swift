import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

struct Printer<T> {
    let item: T
    init(_ item: T) {
        self.item = item
    }
}

enum URLError: Error {
    case invalidInput
    case invalidURL
}

public struct URLMacro: ExpressionMacro {
    
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        let p = Printer(node)
        guard let text = node.argumentList.first?.as(LabeledExprSyntax.self)?.expression.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)?.content.text else {
            throw URLError.invalidInput
        }
        guard URL(string: text) != nil else {
            throw URLError.invalidURL
        }
        return ExprSyntax(stringLiteral: """
        URL(string: "\(text)")!
        """)
    }
}



@main
struct UtilitiesPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        URLMacro.self
    ]
}
