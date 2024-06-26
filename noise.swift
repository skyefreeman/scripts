#!/usr/bin/swift sh
import Foundation
import ArgumentParser // https://github.com/apple/swift-argument-parser.git

// MARK: - Shell

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

// MARK: - Sox

enum Sox {
    enum Play {}
}

extension Sox.Play {

    enum Noise {
        case white 
        case brown 
        case pink
        case sine(freq: String)
        case pluck(note: String)

        var rawValue: String {
            switch self {
            case .white: "whitenoise"
            case .brown: "brownnoise"
            case .pink: "pinknoise"
            case .sine(let freq): "sine \(freq)"
            case .pluck(let note): "pl \(note)"
            }
        }
    }

    static func noise(
        _ noiseType: Noise,
        length: Int? = nil
    ) -> String {
        // -c2 == number of channels, 2 means stereo
        // -n  == null file, just play it

        //tremolo 10 100
        return try! shell("play -c2 -n synth \(length ?? -1) \(noiseType.rawValue)")
        // tremelo 50 1
    }
}

// MARK: - Noise

struct Noise: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Does things",
        usage: "swift sh noise.swift"
    )
    
    mutating func run() throws {
        let result = Sox.Play.noise(.brown)
        print(result)
  //         299  play -c2 -n synth whitenoise band -n 100 24 band -n 300 100 gain +20
  // 300  play -c2 -n synth whitenoise band -n 100 24 band -n 300 100 gain +1
  // 301  play -c2 -n synth whitenoise band -n 100 24 band -n 300 100 gain +30
  // 302  play -c2 -n synth whitenoise band -n 100 24 band -n 300 100
  // 303  play -c2 -n synth pinknoise band -n 100 24 band -n 300 100
  // 304   play -t sl -r48000 -c2 - synth -1 pinknoise tremolo .1 40 <  /dev/zero
  // 305  play -t sl -r48000 -c2 - synth -1 pinknoise tremolo .1 40
  // 306  play -t sl -r48000 -c2 - synth -1 pinknoise tremolo .1 40
  // 307  play -t sl -r48000 -c2 - synth -1 pinknoise .1 40  < /dev/zero
  // 308  play -c2 -n synth whitenoise band -n 100 24 band -n 300 100 gain +30
  // 309  play -t sl -r48000 -c2 - synth -1 pinknoise tremolo .1 40 <  /dev/zero
  // 310  play -n synth 60:00 whitenoise
  // 311  play -n synth 60:00 pinknoise
  // 312  play -n synth 60:00 brownnoise
  // 313  play -n -n --combine merge synth '24:00:00' brownnoise
  // 314  play -n -n --combine merge synth '24:00:00' brownnoise band -n 750 750 tremelo 50 1
  // 315  play -n synth sine 440 trim 0 1 gain -12
  // 316  play -V -n -b 24 -r 48000 synth 10 sine 20/20000
        // play -n synth pl G2 pl B2 pl D3 pl G3 pl D4 pl G4 delay 0 .05 .1 .15 .2 .25 remix - fade 0 4 .1
     // 
    }
}

Noise.main()
