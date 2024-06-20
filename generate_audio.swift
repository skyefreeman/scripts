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

struct GenerateAudio: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Does things",
        usage: "swift sh generate_audio.swift"
    )

    @Argument(help: "The track's title.")
    var trackName: String

    @Argument(help: "The track's artist.")
    var trackArtist: String

    @Argument(help: "The track's album.")
    var trackAlbum: String

    @Argument(help: "The audio track length, in seconds.")
    var length: Int

    @Flag(
        name: .shortAndLong,
        help: "Turns on debug mode."
    )
    var debug: Bool = false
    
    mutating func run() throws {
        let command = ffmpeg(
            outputFilename: outputFilename,
            trackName: trackName,
            length: length
        )
        let output = try! shell(command)

        if debug {
            print(output)
        }
        
        print("Generated: \(outputFilename)")
    }

    private var outputFilename: String {
        return "a_moment_of_silence.mp3"
    }
    
    private func ffmpeg(
        outputFilename: String,
        trackName: String,
        length: Int
    ) -> String {
        return """
            ffmpeg \
            -f lavfi \
            -i anullsrc=r=11025:cl=mono \
            -t \(length) \
            -acodec mp3 \
            -metadata title='\(trackName)' \
            -metadata artist='\(trackArtist)' \
            -metadata album='\(trackAlbum)' \
            \(outputFilename)
            """
    }
}

GenerateAudio.main()
