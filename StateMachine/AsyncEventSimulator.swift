//
//  AsyncEventSimulator.swift
//  StateMachine
//
//  Created by Curt Clifton on 11/9/15.
//  Copyright © 2015 curtclifton.net. All rights reserved.
//

import Foundation

private func makeBackgroundQueue() -> OperationQueue {
    let opQueue = OperationQueue()
    opQueue.qualityOfService = .background
    opQueue.maxConcurrentOperationCount = 2
    return opQueue
}

private let backgroundQueue = makeBackgroundQueue()

func afterDelayOfTimeInterval(_ delay: TimeInterval, performBlockOnMainQueue block: @escaping () -> ()) {
    backgroundQueue.addOperation {
        Thread.sleep(forTimeInterval: delay)
        OperationQueue.main.addOperation {
            block()
        }
    }
}

private let asyncSimulationProgressGranularity = Float(1.0 / 50.0)

func simulateAsyncOperationLasting<State>(seconds: Int,
                                          for stateMachine: StateMachine<State>,
                                          completionEventGenerator completionEvent: @escaping () -> State.EventType,
                                          progressEventGenerator progressEvent: @escaping (Float) -> State.EventType) {
    let durationInSeconds = Double(seconds)
    let progressInterval = durationInSeconds * Double(asyncSimulationProgressGranularity)
    let startTime = Date()
    
    func rescheduleProgress() {
        afterDelayOfTimeInterval(progressInterval) {
            let currentTime = Date()
            let elapsedTimeInterval = currentTime.timeIntervalSince(startTime)
            let progress = Float(elapsedTimeInterval / durationInSeconds)
            stateMachine.processEvent(progressEvent(progress))
            // schedule another update unless it would put us past 100%
            if progress + asyncSimulationProgressGranularity < 1.0 {
                rescheduleProgress()
            }
        }
    }
    
    rescheduleProgress()
    afterDelayOfTimeInterval(durationInSeconds)  {
        stateMachine.processEvent(completionEvent())
    }
}
