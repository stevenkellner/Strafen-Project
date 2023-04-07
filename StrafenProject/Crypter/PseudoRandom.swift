//
//  PseudoRandom.swift
//  StrafenProject
//
//  Created by Steven on 06.04.23.
//

import Foundation

struct PseudoRandom {
    private struct State {
        var state0: Double
        var state1: Double
        var state2: Double
        var constant: Double
    }
        
    private static let initialMash: Double = 0xefc8249d
    
    private var state: State
    
    internal init(seed: [UInt8]) {
        var n = PseudoRandom.initialMash
        PseudoRandom.mash(&n, seed: [0x20])
        var state0 = PseudoRandom.mashResult(n)
        PseudoRandom.mash(&n, seed: [0x20])
        var state1 = PseudoRandom.mashResult(n)
        PseudoRandom.mash(&n, seed: [0x20])
        var state2 = PseudoRandom.mashResult(n)
        PseudoRandom.mash(&n, seed: seed)
        state0 -= PseudoRandom.mashResult(n)
        if state0 < 0 { state0 += 1 }
        PseudoRandom.mash(&n, seed: seed)
        state1 -= PseudoRandom.mashResult(n)
        if state1 < 0 { state1 += 1 }
        PseudoRandom.mash(&n, seed: seed)
        state2 -= PseudoRandom.mashResult(n)
        if state2 < 0 { state2 += 1 }
        self.state = State(state0: state0, state1: state1, state2: state2, constant: 1)
    }
    
    private static func mash(_ n: inout Double, seed: [UInt8]) {
        for byte in seed {
            n += Double(byte)
            var h = 0.02519603282416938 * n
            n = h.rounded(.towardZero)
            h -= n
            h *= n
            n = h.rounded(.towardZero)
            h -= n
            n += h * 0x100000000
        }
    }
    
    private static func mashResult(_ n: Double) -> Double {
        return n.rounded(.towardZero) * 2.3283064365386963e-10
    }
    
    private mutating func random() -> Double {
        let t = 2_091_639 * self.state.state0 + self.state.constant * 2.3283064365386963e-10
        self.state.state0 = self.state.state1
        self.state.state1 = self.state.state2
        self.state.constant = t.rounded(.towardZero)
        self.state.state2 = t - self.state.constant
        return self.state.state2
    }
    
    mutating func randomByte() -> UInt8 {
        return UInt8(self.random() * 256)
    }
}
