//
//  AppDelegate.swift
//  TodosApp
//
//  Created by Maurice on 9/11/19.
//  Copyright © 2019 maurice. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //calling the method that reveals the coredata file
        CoreDataStack.sharedInstance.applicationDocumentsDirectory()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        // Saving changes in the application's managed object context before the application terminates.
        CoreDataStack.sharedInstance.saveContext()
        
    }

    // MARK: - Core Data stack
    // moved to the CoreDataStack class for cleanliness

}

