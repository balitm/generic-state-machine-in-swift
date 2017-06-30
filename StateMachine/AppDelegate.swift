//
//  AppDelegate.swift
//  StateMachine
//
//  Created by Curt Clifton on 11/7/15.
//  Copyright © 2015 curtclifton.net. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var stateMachine: StateMachine<StenciltownState>?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let rvc = window?.rootViewController as? ViewController {
            let stencilTownState = StenciltownState(viewController: rvc)
            stateMachine = StateMachine(state: stencilTownState)
        }
        return true
    }
}

