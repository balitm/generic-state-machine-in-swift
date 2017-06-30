//
//  StenciltownState.swift
//  StateMachine
//
//  Created by Curt Clifton on 11/9/15.
//  Copyright © 2015 curtclifton.net. All rights reserved.
//

import Foundation

protocol StenciltownViewController {
    var viewModel: StenciltownViewModel? { get set }
}

struct StenciltownState: StateMachineState {
    enum State {
        case initial
        case fetching(progress: Float)
        case fetched
        case downloading(progress: Float)
        case downloaded
    }
    
    enum Event {
        case beginFetch
        case fetchProgress(progress: Float)
        case fetchCompleted
        case beginDownload
        case downloadProgress(progress: Float)
        case downloadCompleted
        case reset
    }
    
    fileprivate var viewController: StenciltownViewController
    fileprivate var state: State
    
    init(viewController: StenciltownViewController) {
        self.viewController = viewController
        self.state = State.initial
    }
    
    fileprivate func viewModel(with stateMachine: StateMachine<StenciltownState>) -> StenciltownViewModel {
        switch state {
        case .initial:
            return StenciltownViewModel(description: "", fetchOperation: { stateMachine.processEvent(.beginFetch) } )
        case .fetching(let progress):
            return StenciltownViewModel(description: "Fetching Description…", progressBarHidden: false, progressBarProgress: progress)
        case .fetched:
            return StenciltownViewModel(description: "It’s a bunny", downloadButtonHidden: false, downloadPressOperation: { stateMachine.processEvent(.beginDownload) })
        case .downloading(let progress):
            return StenciltownViewModel(description: "Downloading…", progressBarHidden: false, progressBarProgress: progress)
        case .downloaded:
            return StenciltownViewModel(description: "Isn’t it cute?")
        }
    }
    
    mutating func resetToInitialState(with stateMachine: StateMachine<StenciltownState>) {
        self.state = State.initial
        viewController.viewModel = viewModel(with: stateMachine)
    }
    
    mutating func transition(with event: Event) -> TransitionOutcome<StenciltownState> {
        let previousState = self
        switch (state, event) {
        case (.initial, .beginFetch):
            state = .fetching(progress: 0.0)
        case (.fetching, .fetchProgress(let progress)):
            state = .fetching(progress: progress)
            return .sameState
        case (.fetching, .fetchCompleted):
            state = .fetched
        case (.fetched, .beginDownload):
            state = .downloading(progress: 0.0)
        case (.downloading, .downloadProgress(let progress)):
            state = .downloading(progress: progress)
            return .sameState
        case (.downloading, .downloadCompleted):
            state = .downloaded
        case (_, .reset):
            state = .initial
        default:
            // could conceivably transition to error state if we got an unexpected event, but for now just ignore it
            return .sameState
        }
        return .newState(previousState: previousState)
    }
    
    func takePreTransitionAction(for event: Event, with stateMachine: StateMachine<StenciltownState>) {
        switch event {
        case .beginFetch:
            // For simulation, we schedule a progress update and a fetch completed. In reality we would start the async fetch and need to poke the state machine with actual progress.
            simulateAsyncOperationLastingSeconds(5, forStateMachine: stateMachine, completionEventGenerator: { .fetchCompleted }, progressEventGenerator: { .fetchProgress(progress: $0) })
        case .beginDownload:
            // For simulation, we schedule a progress update and a download completed. In reality we would start the async fetch and need to poke the state machine with actual progress.
            simulateAsyncOperationLastingSeconds(10, forStateMachine: stateMachine, completionEventGenerator: { .downloadCompleted }, progressEventGenerator: { .downloadProgress(progress: $0) })
        case .reset: // CCC, 11/7/2015. currently no way to trigger in the UI
            // CCC, 11/7/2015. purge the background queue?
            break
        default:
            // Let state transitions handle
            break
        }
    }
    
    mutating func takePostTransitionAction(for event: Event, with stateMachine: StateMachine<StenciltownState>) {
        viewController.viewModel = viewModel(with: stateMachine)
    }
}

struct StenciltownViewModel {
    let stateDescription: String
    let downloadButtonHidden: Bool
    let progressBarHidden: Bool
    let progressBarProgress: Float
    fileprivate let fetchOperation: (() -> Void)?
    fileprivate let downloadPressOperation: (() -> Void)?
    var downloadButtonEnabled: Bool {
        return downloadPressOperation != nil
    }
    
    init(description: String, downloadButtonHidden: Bool = true, progressBarHidden: Bool = true, progressBarProgress: Float = 0.0, fetchOperation: (() -> Void)? = nil, downloadPressOperation: (() -> Void)? = nil) {
        self.stateDescription = description
        self.downloadButtonHidden = downloadButtonHidden
        self.progressBarHidden = progressBarHidden
        self.progressBarProgress = progressBarProgress
        self.fetchOperation = fetchOperation
        self.downloadPressOperation = downloadPressOperation
    }
    
    func download() {
        downloadPressOperation?()
    }
    
    func beginFetch() {
        fetchOperation?()
    }
}
