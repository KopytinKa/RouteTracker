//
//  AppDelegate.swift
//  RouteTracker
//
//  Created by Кирилл Копытин on 09.03.2022.
//

import UIKit
import GoogleMaps
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator?
    var visualEffectView = UIVisualEffectView()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, erro in
            guard granted else {
                print("Разрешение не получено")
                return
            }
        }
        
        GMSServices.provideAPIKey("AIzaSyBhBKNoqxDUL3PjU_8riBL5lITFQqqTV8s")
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        coordinator = AppCoordinator()
        coordinator?.start()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.sendNotificationRequest(
            content: self.makeNotificationContent(),
            trigger: self.makeIntervalNotificationTrigger()
        )
    }
        
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.visualEffectView.removeFromSuperview()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if !self.visualEffectView.isDescendant(of: self.window!) {
            let blurEffect = UIBlurEffect(style: .light)
            self.visualEffectView = UIVisualEffectView(effect: blurEffect)
            self.visualEffectView.frame = (self.window?.bounds)!
            self.window?.addSubview(self.visualEffectView)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.visualEffectView.removeFromSuperview()
    }
    
    func sendNotificationRequest(content: UNNotificationContent, trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(
            identifier: "alarm",
            content: content,
            trigger: trigger
        )
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func makeNotificationContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Ты куда пропал?"
        content.subtitle = "Вернись!"
        content.body = "Я ВСЕ ПРОЩУ!"
        return content
    }
    
    func makeIntervalNotificationTrigger() -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger (timeInterval: 20, repeats: false)
    }
}

