//
//  main.swift
//  MarkdownConverter Convert Swift Playgrounds to Markdown and back.
//
// //: ## A handy utilty that converts a markdown file into a playground markdown file and
//: the otherway around.
//  Created by Paul Ossenbruggen on 10/22/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

import Foundation

struct Converter {
    public static func toPlayground(text: String) -> String {
        let lines = toMatches(text: text)
        return matchesToPlayground(lines: lines)
    }
    
    public static func toMarkdown(text: String) -> String {
        let lines = toMatches(text: text)
        return matchesToMarkdown(lines: lines)
    }

    private static func toMatches(text: String) -> [String] {
        // Swift currently does not have regex built into stanard library.
        func matches(for regex: String, in text: String) -> [String] {
            do {
                let regex = try NSRegularExpression(pattern: regex, options: [] )
                let range = NSRange(text.startIndex..<text.endIndex, in: text)
                let results = regex.matches(in: text, range: range)
                let res:[String] = results.map {
                    let range = Range($0.range, in: text)!
                    return String(text[range])
                }
                return res
            } catch let error {
                print("invalid regex: \(error.localizedDescription)")
                return []
            }
        }
        return matches(for: ".*", in: text)
    }
    
    private static func matchesToPlayground(lines: [String]) -> String {
        let result:[[String]] = [["/*:"]] + lines.map { line in
            if line.hasPrefix("``` swift") {
                return ["*/"]
            } else if line.hasPrefix("```") {
                return ["/*:"]
            } else if line.isEmpty {
                return []
            } else {
                return [line]
            }
            } + [["*/"]]
        let flat = result.flatMap { $0 }
        return flat.joined(separator: "\n")
    }
    
    private static func matchesToMarkdown(lines: [String]) -> String {
        func replace(prefix: String, line: String) -> String {
            return String(line[prefix.endIndex...])
        }
        
        let result: [[String]] = lines.map { line in
            if line.hasPrefix("/*:") {
                return [replace(prefix: "/*:", line: line), "```"]
            } else if line.hasPrefix("//:") {
                return [replace(prefix: "//:", line: line)]
            } else if line.hasPrefix("*/") {
                return [replace(prefix: "*/", line: line),  "``` swift"]
            } else if line.isEmpty {
                return []
            } else {
                return [line]
            }
        }
        let flattenResult = (result.dropFirst().dropLast()).flatMap { $0 }
        return flattenResult.joined(separator: "\n")
    }
}

struct CommandTool {
    struct ArgHandler {
        let short: String?
        let long: String?
        let help: String
        let command: ((String) throws -> String)?
    }
    let description: String
    let handlers: [ArgHandler]
    
    func displayHelp() -> String {
        func pad(from string: String, to count: Int) -> String {
            if string.count > count {
                return string
            }
            return string + (string.count..<count).reduce("") { accumulate, _ in accumulate + " " }
        }
        return description + "\n" + handlers.reduce("") {
            let short = $1.short ?? ""
            let long = $1.long ?? ""
            let shortFormat = pad(from: short, to: 3)
            let longFormat = pad(from: long, to: 20)
            return $0 + "\n  \(shortFormat) \(longFormat) \($1.help)"
        } + "\n"
    }
    
    func callMatching(operation: String, text: String) throws -> String {
        let found = handlers.filter { operation == $0.short || operation == $0.long }
        for handler in found {
            if let command = handler.command {
                return try command(text)
            } else {
                return displayHelp()
            }
        }
        return displayHelp()
    }
}

func parseCommandLine(args: [String]) throws -> (String) {
    func loadText(path: String) throws -> String {
        let url = URL(fileURLWithPath: path)
        return try String(contentsOf: url)
    }

    let commandTool = CommandTool(
        description: """

        Markdown Converter:

        Tool for convering Swift Playgrounds into or out of Markdown(.md) format so they can be displayed in Github nicely.
        """,
        handlers: [
            CommandTool.ArgHandler(short: "-p",
                                   long: "--toPlayground",
                                   help: "[Markdown File Path] Converts from Markdown file to Playground.") { path in
                                    let text = try loadText(path: path)
                                    return Converter.toPlayground(text: text)
            },
            CommandTool.ArgHandler(short: "-m",
                                   long: "--toMarkdown",
                                   help: "[Playground File Path] Converts from Playground file to Markdown.") { path in
                                    let text = try loadText(path: path)
                                    return Converter.toMarkdown(text: text)
            },
            CommandTool.ArgHandler(short: "-h",
                                   long: "--help",
                                   help: "This help", command: nil)
        ])
    guard args.count == 3 else {
        return commandTool.displayHelp()
    }
    let operation = args[1]
    let path = args[2]
    return try commandTool.callMatching(operation: operation, text: path)
}

let cl = CommandLine.arguments
print(try parseCommandLine(args: cl))
