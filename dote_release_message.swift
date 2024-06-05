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

struct DoteReleaseMessage: ParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "Generates a shareable release message for Dote.",
        usage: "swift sh dote_release_message.swift"
    )

    mutating func run() throws {
        // get all tags
        let tags: [String] = {
            let raw = try! shell("git tag")
            return raw
                .split(whereSeparator: \.isNewline)
                .map({ String($0) })
                .filter({ $0.contains("dote-") })
                .sorted()
                .reversed()
        }()

        // collect commits into message using most recent 2 tags
        let commits = try! shell("collect_release_commits.swift \(tags[1]) \(tags[0])")
        
        // format commits into links
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

            temp.insert(
                contentsOf: "](https://github.com/pushd/photo-journal-ios/pull/\(pr))",
                at: temp.index(temp.startIndex, offsetBy: 10)
            )
            temp.insert(contentsOf: "[", at: temp.startIndex)
            temp.insert(contentsOf: "\n", at: temp.endIndex)
            formattedCommits += temp
        }

        // put it all together
        let finalMessage = releaseMessageTemplate(
            version: tags[0].replacingOccurrences(of: "dote-", with: ""),
            commits: formattedCommits
        )
        print(finalMessage)
    }

    private func releaseMessageTemplate(version: String, commits: String) -> String {
        return """
:siren_gif: Dote Release \(version) is available via TestFlight and is pending app store review :siren_gif:

This release includes:

- 

*New commits in version \(version)*

\(commits)
"""
    }
}

DoteReleaseMessage.main()
