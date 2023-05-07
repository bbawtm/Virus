//
//  VirusEngine.swift
//  Virus
//
//  Created by Vadim Popov on 07.05.2023.
//

import UIKit


final class VirusEngine {
    
    private let desk: Desk
    private let infectionFactor: Int
    private let timeInterval: Float
    private var refreshStat: ((Int, Int) -> Void)?
    private let taskManagerQueue = DispatchQueue(label: "VadimPopov.Virus.Engine.TaskManagerQueue")
    private let concurrentQueue = DispatchQueue(label: "VadimPopov.Virus.Engine.ConcurrentQueue", attributes: .concurrent)
    
    public init(
        _ groupSize: Int,
        _ infectionFactor: Int,
        _ timeInterval: Float
    ) {
        self.desk = Desk(count: groupSize)
        self.infectionFactor = infectionFactor
        self.timeInterval = timeInterval
    }
    
    public func getDesk() -> DeskState {
        return desk
    }
    
    public func connectUI(
        columnsCount: Int
    ) {
        desk.columnsCount = columnsCount
        
        Timer.scheduledTimer(withTimeInterval: Double(self.timeInterval), repeats: true) { [self] _ in
            DispatchQueue.main.async { [self] in
                coordinator.getReference(for: DeskVC.self).reloadAll()
                desk.buf = []
                
                concurrentQueue.async { [self] in
                    for i in 0..<desk.values.count {
                        addTask(forItem: i)
                    }
                }
            }
        }
    }
    
    public func addInfected(_ ind: Int) {
        guard ind >= 0 && ind < desk.values.count && !desk.values[ind] else { return }
        desk.values[ind] = true
        desk.sick += 1
        addTask(forItem: ind)
    }
    
    private func addTask(forItem item: Int) {
        guard desk.values[item], let columnsCount = desk.columnsCount else { return }
        let valuesCopy = desk.values
        concurrentQueue.async { [self] in
            var neighbours: [Int] = []
            let mn = item - columnsCount
            let mx = item + columnsCount
            for i in -1...1 {
                if mn + i >= 0 && mn + i < valuesCopy.count && !valuesCopy[mn + i] {
                    neighbours.append(mn + i)
                }
                if mx + i >= 0 && mx + i < valuesCopy.count && !valuesCopy[mx + i] {
                    neighbours.append(mx + i)
                }
                if i != 0 && item + i >= 0 && item + i < valuesCopy.count && !valuesCopy[item + i] {
                    neighbours.append(item + i)
                }
            }
            var res: [Int] = []
            if infectionFactor >= neighbours.count {
                res = neighbours
            } else {
                for _ in 0..<infectionFactor {
                    res.append(neighbours.remove(at: Int.random(in: 0..<neighbours.count)))
                }
            }
            DispatchQueue.main.async { [self] in
                for newInd in res {
                    if !desk.values[newInd] {
                        desk.values[newInd] = true
                        desk.sick += 1
                        desk.buf.append(newInd)
                    }
                }
            }
        }
    }
    
    
    private final class Desk: DeskState {
        
        let count: Int
        var sick: Int = 0
        var columnsCount: Int?
        var values: [Bool]
        var buf: [Int] = []
        
        init(count: Int) {
            self.count = count
            self.values = .init(repeating: false, count: count)
        }
        
    }
    
}
