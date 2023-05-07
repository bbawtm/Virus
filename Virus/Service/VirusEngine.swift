//
//  VirusEngine.swift
//  Virus
//
//  Created by Vadim Popov on 07.05.2023.
//

import UIKit


final class VirusEngine {
    
    private let desk: Desk
    
    public init(
        _ groupSize: Int,
        _ infectionFactor: Int,
        _ timeInterval: Float
    ) {
        desk = Desk(count: groupSize)
    }
    
    public func getDesk() -> DeskState {
        return desk
    }
    
    private final class Desk: DeskState {
        
        let count: Int
        let values: [Bool]
        
        init(count: Int) {
            self.count = count
            self.values = .init(repeating: false, count: count)
        }
        
    }
    
}
