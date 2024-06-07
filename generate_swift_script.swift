#!/usr/bin/swift sh

import Foundation
import ArgumentParser // https://github.com/apple/swift-argument-parser.git

// MARK: - String Extensions

extension String {

    func snakeCased() -> String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        return regex.stringByReplacingMatches(
            in: self,
            options: [],
            range: range,
            withTemplate: "$1_$2"
        ).lowercased()
    }
}

// MARK: - Utilities

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

// MARK: - GenerateSwiftScript

struct GenerateSwiftScript: ParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "Generate a new Swift script file.",
        usage: "swift sh generate_swift_script.swift \"new_script.swift\""
    )
    
    @Argument(help: "The script command name, in snakecase format.")
    var command: String
    
    mutating func run() throws {
        let fileManager = FileManager.default
        let path = fileManager.currentDirectoryPath
        let output = createNewFileContents(commandName: command)
            .replacingOccurrences(of: "// import", with: "import")
        let outputFilename = "\(command.snakeCased()).swift"
        let outputFilepath = "\(path)/\(outputFilename)"

        guard !fileManager.fileExists(atPath: outputFilepath) else {
            print("File already exists at path: \(outputFilepath)")
            Self.exit()
        }

        guard fileManager.createFile(
            atPath: outputFilepath,
            contents: output.data(using: .utf8)
        ) else {
            print("Failed to create file at path: \(outputFilepath)")
            Self.exit()
        }

        do {
            try shell("chmod u+x \(outputFilepath)")
            print("Created script: \(outputFilepath)")
        } catch {
            Self.exit(withError: error)
        }
    }

    private func createNewFileContents(commandName: String) -> String {
        return """
            #!/usr/bin/swift sh
            import Foundation
            // import ArgumentParser // https://github.com/apple/swift-argument-parser.git

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
            
            struct \(commandName): ParsableCommand {
                static let configuration = CommandConfiguration(
                    abstract: "Does things",
                    usage: "swift sh \(commandName.snakeCased()).swift"
                )
            
                mutating func run() throws {
                    print("This works.")
                }
            }

            \(commandName).main()
            """
    }
}

// MARK: - Main

GenerateSwiftScript.main()
