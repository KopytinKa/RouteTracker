//
//  AuthCoordinator.swift
//  RouteTracker
//
//  Created by Кирилл Копытин on 04.06.2022.
//

import Foundation
import UIKit

final class AuthCoordinator: BaseCoordinator {
    
    var rootController: UINavigationController?
    
    override func start() {
        showLoginModule()
    }
    
    private func showLoginModule() {
        guard
            let controller = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        else { return }
        
        controller.onLogin = { [weak self] in
            self?.showMapModule()
        }
        
        controller.onRegister = { [weak self] in
            self?.showMapModule()
        }
        
        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
    }
    
    private func showMapModule() {
        guard
            let controller = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
        else { return }
        
        rootController?.pushViewController(controller, animated: true)
    }
}
