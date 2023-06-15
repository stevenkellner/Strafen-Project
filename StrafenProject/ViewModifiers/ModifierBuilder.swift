//
//  ModifierBuilder.swift
//  StrafenProject
//
//  Created by Steven on 10.06.23.
//

import SwiftUI

@resultBuilder
struct ModifierBuilder {    
    static func buildPartialBlock(first: some ViewModifier) -> some ViewModifier {
        return first
    }
    
    static func buildPartialBlock(accumulated: some ViewModifier, next: some ViewModifier) -> some ViewModifier {
        return PairModifier(first: accumulated, second: next)
    }
    
    static func buildEither(first modifier: some ViewModifier) -> some ViewModifier {
        return ConditionalModifier(alwaysTrue: modifier)
    }
    
    static func buildEither(second modifier: some ViewModifier) -> some ViewModifier {
        return ConditionalModifier(alwaysFalse: modifier)
    }
    
    static func buildOptional(_ modifier: (some ViewModifier)?) -> some ViewModifier {
        return OptionalModifier(modifier: modifier)
    }
}

struct PairModifier<FirstModifier, SecondModifier>: ViewModifier where FirstModifier: ViewModifier, SecondModifier: ViewModifier {
    
    private let firstModifier: FirstModifier
    
    private let secondModifier: SecondModifier
    
    init(first firstModifier: FirstModifier, second secondModifier: SecondModifier) {
        self.firstModifier = firstModifier
        self.secondModifier = secondModifier
    }
    
    func body(content: Content) -> some View {
        content
            .modifier(self.firstModifier)
            .modifier(self.secondModifier)
    }
}

struct ConditionalModifier<TrueModifier, FalseModifier>: ViewModifier where TrueModifier: ViewModifier, FalseModifier: ViewModifier {
    
    private let condition: Bool
    
    private let trueModifier: TrueModifier
    
    private let falseModifier: FalseModifier
    
    init(condition: Bool, trueModifier: TrueModifier, falseModifier: FalseModifier) {
        self.condition = condition
        self.trueModifier = trueModifier
        self.falseModifier = falseModifier
    }
    
    func body(content: Content) -> some View {
        if self.condition {
            content
                .modifier(self.trueModifier)
        } else {
            content
                .modifier(self.falseModifier)
        }
    }
}

extension ConditionalModifier where FalseModifier == EmptyModifier {
    init(alwaysTrue modifier: TrueModifier) {
        self.condition = true
        self.trueModifier = modifier
        self.falseModifier = EmptyModifier()
    }
}

extension ConditionalModifier where TrueModifier == EmptyModifier {
    init(alwaysFalse modifier: FalseModifier) {
        self.condition = true
        self.trueModifier = EmptyModifier()
        self.falseModifier = modifier
    }
}

struct OptionalModifier<Modifier>: ViewModifier where Modifier: ViewModifier {
    
    private let modifier: Modifier?
    
    init(modifier: Modifier?) {
        self.modifier = modifier
    }
    
    func body(content: Content) -> some View {
        if let modifier = self.modifier {
            content
                .modifier(modifier)
        } else {
            content
        }
    }
}
