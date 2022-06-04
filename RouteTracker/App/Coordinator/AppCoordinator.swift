//
//  AppCoordinator.swift
//  RouteTracker
//
//  Created by Кирилл Копытин on 04.06.2022.
//

import Foundation

final class AppCoordinator: BaseCoordinator {
    
    override func start() {
        toAuth()
    }
    
    private func toAuth() {
        let coordinator = AuthCoordinator()
        addDependency(coordinator)
        coordinator.start()
    }
}
