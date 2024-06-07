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

struct SemanticVersion {
    let major: Int
    let minor: Int

    init(major: Int, minor: Int) {
        self.major = major
        self.minor = minor
    }

    init(with version: String) {
        let cleaned = version.replacingOccurrences(of: "dote-", with: "")
        let components = cleaned.components(separatedBy: ".")
        self.major = Int(components[0])!
        self.minor = Int(components[1])!
    }

    var incrementedMajor: SemanticVersion {
        return SemanticVersion(major: major + 1, minor: minor)
    }

    var incrementedMinor: SemanticVersion {
        return SemanticVersion(major: major, minor: minor + 1)
    }
    
    var humanReadable: String {
        return "\(major).\(minor)"
    }

    var tag: String {
        return "dote-\(humanReadable)"
    }
}

struct DoteRelease: ParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "Creates a Dote release and generates a shareable message with all changes since last release.",
        usage: "swift sh dote_release.swift"
    )

    @Flag(
        name: .shortAndLong,
        help: "Bump the release version by incrementing the current tag number."
    )
    var bumpVersion: Bool = false

    mutating func run() throws {
        // get all current tags, creating a new one if the bumpVersion flag is set.
        let tags: [String] = {
            let tags: [String] = try! shell("git tag")
                .split(whereSeparator: \.isNewline)
                .map({ String($0) })
                .filter({ $0.contains("dote-") })
                .sorted()
                .reversed()

            guard bumpVersion else {
                return tags
            }
            
            let newTag = SemanticVersion(with: tags[0])
                .incrementedMinor
                .tag
            
            return [newTag] + tags
        }()

        let newVersion = SemanticVersion(with: tags[0]) 
        let previousVersion = SemanticVersion(with: tags[1])

        // commit and push the new tag, if needed
        if bumpVersion {
            try! shell("git tag \(newVersion.tag) && git push origin --tags")
        }
        
        // collect commits into message using most recent 2 tags
        let commits = try! shell("collect_release_commits.swift \(previousVersion.tag) \(newVersion.tag)")
        
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
            version: newVersion.humanReadable,
            commits: formattedCommits
        )
        print(finalMessage)
    }

    private func releaseMessageTemplate(version: String, commits: String) -> String {
        return """
:siren_gif: *Dote Version \(version) is building for App Store release* :siren_gif:

*What's New*

- 

*Commit Log \(version)*

\(commits)
"""
    }
}

DoteRelease.main()
