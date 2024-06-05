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

struct CollectReleaseCommits: ParsableCommand {

    @Argument(help: "The starting commit or tag.")
    var start: String

    @Argument(help: "The ending commit or tag.")
    var end: String
    
    static let configuration = CommandConfiguration(
        abstract: "Given two commit hashes or tags, return a list of single line commits.",
        usage: "swift sh collect_release_commits.swift <start> <end>"
    )

    mutating func run() throws {
        let result = try! shell("git log --oneline \(start)..\(end)")
        print(result)
    }
}

CollectReleaseCommits.main()
