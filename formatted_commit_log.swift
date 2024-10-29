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

struct FormattedCommitLog: ParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "Does things",
        usage: "swift sh formatted_commit_log.swift"
    )

    mutating func run() throws {
        let commits = try! shell("git log --oneline -10")
        let formatted = formatted(commits: commits)
        print(formatted)
    }

    private func formatted(commits: String) -> String {
        let urlBase = remoteURL()
        var formattedCommits = ""
        for line in commits.split(whereSeparator: \.isNewline) {
            var temp = line

            let pr: String = {
                guard let found = temp.range(of: "(#") else {
                    return ""
                }
                
                let substring = temp[found.lowerBound..<temp.endIndex]
                return substring.filter({ !["#", "(", ")"].contains($0) })
            }()
            
            let hash = line.split(separator: " ").first!
            temp.insert(
                contentsOf: "](\(urlBase)/pull/\(pr))",
                at: temp.index(temp.startIndex, offsetBy: hash.count)
            )
            temp.insert(contentsOf: "[", at: temp.startIndex)
            temp.insert(contentsOf: "\n", at: temp.endIndex)
            formattedCommits += temp
        }
        return formattedCommits
    }
    
    private func remoteURL() -> String {
        let urlString = try! shell("git config --get remote.origin.url")
        let items = urlString.split(separator: ":")
        let base = items.first!.split(separator: "@").last!
        let path = items.last!.split(separator: "/")
        let org = path.first!
        let repo = path.last!.split(separator: ".").first!
        return "https://\(base)/\(org)/\(repo)"
    }
    
}

FormattedCommitLog.main()
