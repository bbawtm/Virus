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
    private var timer: DispatchSourceTimer?
    private var taskManagerQueueKey: Int = 0
    
    public init(
        _ groupSize: Int,
        _ infectionFactor: Int,
        _ timeInterval: Float
    ) {
        self.desk = Desk(count: groupSize)
        self.infectionFactor = infectionFactor
        self.timeInterval = timeInterval
    }
    
    deinit {
        timer = nil
    }
    
    public func getDesk() -> DeskState {
        return desk
    }
    
    public func connectUI(
        columnsCount: Int
    ) {
        desk.columnsCount = columnsCount
        
        let timer = DispatchSource.makeTimerSource(queue: taskManagerQueue)
        timer.setEventHandler { [unowned self] in
            if taskManagerQueueKey > 0 {
                return
            }
            taskManagerQueueKey = 1
            DispatchQueue.main.async { [unowned self] in
                if !desk.buf.isEmpty {
                    coordinator.getReference(for: DeskVC.self).reloadAll()
                    desk.buf = []
                }
                if desk.sick == desk.count {
                    self.timer = nil
                    return
                }
                
                taskManagerQueue.async { [unowned self] in
                    for i in 0..<desk.values.count {
                        addTask(forItem: i)
                    }
                    taskManagerQueueKey -= 1
                }
            }
        }
        let micro = Int(pow(10, 6) * self.timeInterval)
        timer.schedule(deadline: .now(), repeating: .microseconds(micro), leeway: .microseconds(micro / 10))
        timer.resume()
        self.timer = timer
    }
    
    public func addInfected(_ ind: Int) {
        guard ind >= 0 && ind < desk.values.count && !desk.values[ind] else { return }
        desk.values[ind] = true
        desk.sick += 1
        addTask(forItem: ind)
    }
    
    private func addTask(forItem item: Int) {
        guard desk.values[item], let columnsCount = desk.columnsCount else { return }
        taskManagerQueueKey += 1
        let valuesCopy = desk.values
        concurrentQueue.async { [unowned self] in
            var neighbours: [Int] = []
            let mn = item - columnsCount
            let mx = item + columnsCount
            for i in -1...1 {
                if mn + i >= 0 && mn + i < valuesCopy.count {
                    neighbours.append(mn + i)
                }
                if mx + i >= 0 && mx + i < valuesCopy.count {
                    neighbours.append(mx + i)
                }
                if i != 0 && item + i >= 0 && item + i < valuesCopy.count {
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
            DispatchQueue.main.async { [unowned self] in
                for newInd in res {
                    if !desk.values[newInd] {
                        desk.values[newInd] = true
                        desk.sick += 1
                        desk.buf.append(newInd)
                    }
                }
                taskManagerQueue.async { [unowned self] in
                    taskManagerQueueKey -= 1
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
