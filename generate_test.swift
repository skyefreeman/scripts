#!/usr/bin/swift sh
import Foundation
import ArgumentParser // https://github.com/apple/swift-argument-parser.git

@discardableResult
func shell(_ command: String) throws -> String {
    let pipe = Pipe()
    let task = Process()
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/bash")
    task.standardInput = nil
    try task.run()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)!
}

struct GenerateTest: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Does things",
        usage: "swift sh generate_test.swift"
    )

    mutating func run() throws {
        print("This works.")
    }
}

GenerateTest.main()