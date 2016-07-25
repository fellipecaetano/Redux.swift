//
//  AppDelegate.swift
//  ReduxCounterExample
//
//  Created by Fellipe Caetano on 7/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let store = CounterStore()

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let counterViewController = window?.rootViewController as? CounterViewController
        counterViewController?.connect(to: store)
        return true
    }
}
