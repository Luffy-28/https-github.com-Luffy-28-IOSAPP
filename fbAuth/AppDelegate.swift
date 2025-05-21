//
//  AppDelegate.swift
//  fbAuth
//
//  Created by shankar singh on 19/05/2025.
//

import UIKit
import FacebookCore
import FirebaseCore
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Initialize Firebase
        FirebaseApp.configure()

        // Initialize Facebook SDK
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // You can leave this as-is
    }

    // MARK: - Facebook Login Redirect Handler

    func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey : Any] = [:]
        ) -> Bool {
            // Handle both Facebook and Google Sign-In
            let handledByFB = ApplicationDelegate.shared.application(app, open: url, options: options)
            let handledByGoogle = GIDSignIn.sharedInstance.handle(url)
            return handledByFB || handledByGoogle
        }
    }
