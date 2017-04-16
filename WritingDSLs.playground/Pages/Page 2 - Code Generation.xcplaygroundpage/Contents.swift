//: Shallow DSL for Code Generation
import Foundation

typealias CodeGenerator = () -> [String]

prefix operator -->

prefix func --> (strs: [String]) -> String {
    return strs.flatMap {
        $0.components(separatedBy: "\n").map { "  " + $0 }
    }.joined(separator: "\n")
}

prefix func --> (body: CodeGenerator) -> String {
    return -->body()
}

func ifStmt(_ condition: String,
            _ body: CodeGenerator) -> [String] {
    return [
        "if \(condition) {",
        -->body,
        "}"
    ]
}

func elseStmt(_ body: CodeGenerator) -> [String] {
    return [
        " else {",
        -->body,
        "}"
    ]
}

func ifElseStmt(_ condition: String,
                body: @escaping CodeGenerator) -> (CodeGenerator) -> [String] {
    return { elseBody in [
        ifStmt(condition, body),
        elseStmt(elseBody)
        ].flatMap { $0 }
    }
}

let fibIfElse = ifElseStmt("i <= 2") {[
    // If
    "return 1"
]} ({[
    // Else
    "return fibonacci(i - 1) + fibonacci(i - 2)"
]})

print(fibIfElse.joined(separator: "\n"))


enum SwitchCase {
    case Case(String, CodeGenerator)
    case Default(CodeGenerator)

    func render() -> [String] {
        switch self {
        case .Case(let condition, let body):
            return [
                "case \(condition):",
                -->body
            ]
        case .Default(let body):
            return [
                "default:",
                -->body
            ]
        }
    }
}

func switchStmt(_ switchVariable: String, body: () -> [SwitchCase]) -> [String] {
    return ["switch (\(switchVariable)) {"] +
                body().map { $0.render() }.flatMap { $0 } +
            ["}"]
}


let fib = switchStmt("i") {[
    .Case("0") {[
        "return 1"
        ]},
    .Case("1") {[
        "return 1"
        ]},
    .Default {[
        "return fibonacci(i - 1) + fibonacci(i - 2)"
        ]}
    ]}

print(fib.joined(separator: "\n"))

//: [Previous](@previous) [Next](@next)

