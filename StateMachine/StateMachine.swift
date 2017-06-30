//
//  StateMachine.swift
//  StateMachine
//
//  Created by Curt Clifton on 11/7/15.
//  Copyright © 2015 curtclifton.net. All rights reserved.
//

import Foundation

protocol StateMachineState {
    associatedtype EventType
    
    mutating func resetToInitialState(with stateMachine: StateMachine<Self>)
    
    mutating func transition(with event: EventType) -> TransitionOutcome<Self>

    mutating func takePreTransitionAction(for event: EventType, with stateMachine: StateMachine<Self>)
    mutating func takeEnterStateAction(with stateMachine: StateMachine<Self>)
    mutating func takeExitStateAction(with stateMachine: StateMachine<Self>)
    mutating func takePostTransitionAction(for event: EventType, with stateMachine: StateMachine<Self>)
}

// Default action methods are no-ops
extension StateMachineState {
    mutating func takePreTransitionAction(for event: EventType, with stateMachine: StateMachine<Self>) {
        // override if there’s work to be done
    }
    
    mutating func takeEnterStateAction(with stateMachine: StateMachine<Self>)  {
        // override if there’s work to be done
    }
    
    mutating func takeExitStateAction(with stateMachine: StateMachine<Self>)  {
        // override if there’s work to be done
    }
    
    mutating func takePostTransitionAction(for event: EventType, with stateMachine: StateMachine<Self>)  {
        // override if there’s work to be done
    }
}

enum TransitionOutcome<State: StateMachineState> {
    case newState(previousState: State)
    case sameState
}

class StateMachine<State: StateMachineState> {
    var state: State
    
    init(state: State) {
        self.state = state
        self.state.resetToInitialState(with: self)
    }

    func processEvent(_ event: State.EventType) {
        state.takePreTransitionAction(for: event, with: self)
        let outcome = state.transition(with: event)
        switch outcome {
        case .newState(var previousState):
            previousState.takeExitStateAction(with: self)
            state.takeEnterStateAction(with: self)
        case .sameState:
            break
        }
        state.takePostTransitionAction(for: event, with: self)
    }
}
