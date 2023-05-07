//
//  Router.swift
//  Virus
//
//  Created by Vadim Popov on 07.05.2023.
//

import UIKit


final class Router {
    
    private let navigationContoller: UINavigationController
    
    public init(navigationContoller: UINavigationController) {
        self.navigationContoller = navigationContoller
    }
    
    public func switchToDesk(
        _ groupSizeStr: String,
        _ infectionFactorStr: String,
        _ timeIntervalStr: String
    ) {
        guard let groupSize = Int(groupSizeStr),
              let infectionFactor = Int(infectionFactorStr),
              let timeInterval = Float(timeIntervalStr)
        else {
            print("MainVC provides incorrect data")
            return
        }
        
        let virusEngine = VirusEngine(groupSize, infectionFactor, timeInterval)
        coordinator.setReference(with: virusEngine)
        let deskVC = coordinator.getReference(for: DeskVC.self)
        deskVC.linkDesk(virusEngine.getDesk())
        navigationContoller.pushViewController(deskVC, animated: true)
    }
    
    public func switchToMain() {
        navigationContoller.popViewController(animated: true)
    }
    
}
