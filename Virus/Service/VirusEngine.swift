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
        taskManagerQueueKey = 0
    }
    
    /**
     Returnes the DeskState as a reference
     */
    public func getDesk() -> DeskState {
        return desk
    }
    
    public func connectUI(
        columnsCount: Int,
        reloadUI: @escaping () -> Void
    ) {
        desk.columnsCount = columnsCount
        
        let timer = DispatchSource.makeTimerSource(queue: taskManagerQueue)
        timer.setEventHandler { [unowned self] in
            if taskManagerQueueKey > 0 {
                return
            }
            taskManagerQueueKey = 1
            DispatchQueue.main.async { [unowned self] in
                reloadUI()
                desk.buf = []
                
                taskManagerQueue.async { [unowned self] in
                    if desk.sick == desk.count {
                        self.timer = nil
                        taskManagerQueueKey -= 1
                        return
                    }
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
        guard ind >= 0 && ind < desk.values.count else { return }
        taskManagerQueue.async { [unowned self] in
            guard !desk.values[ind] else { return }
            desk.values[ind] = true
            desk.sick += 1
            addTask(forItem: ind)
        }
    }
    
    public func isRunning() -> Bool {
        return timer != nil
    }
    
    private func addTask(forItem item: Int) {
        guard desk.values[item], let columnsCount = desk.columnsCount else { return }
        taskManagerQueueKey += 1
        
        var needToCalc = false
        if desk.neighbours[item].count == 0 {
            needToCalc = true
        } else {
            for neighbour in desk.neighbours[item] {
                if !desk.values[neighbour] {
                    needToCalc = true
                }
            }
        }
        if !needToCalc {
            taskManagerQueueKey -= 1
            return
        }
        
        concurrentQueue.async { [unowned self] in
            if desk.neighbours[item].count == 0 {
                let checkAndAdd: (Int) -> Void = { ind in
                    if ind >= 0 && ind < self.desk.values.count {
                        self.desk.neighbours[item].insert(ind)
                    }
                }
                var range = stride(from: -1, through: 1, by: 1)
                if columnsCount == 1 {
                    range = stride(from: 0, through: 0, by: 1)
                } else if item % columnsCount == 0 {
                    range = stride(from: 0, through: 1, by: 1)
                } else if (item + 1) % columnsCount == 0 {
                    range = stride(from: -1, through: 0, by: 1)
                }
                for i in range {
                    checkAndAdd(item - columnsCount + i)
                    checkAndAdd(item + columnsCount + i)
                    if i != 0 {
                        checkAndAdd(item + i)
                    }
                }
            }
            var neighbours = Array(desk.neighbours[item])
                
            var res: [Int] = []
            if infectionFactor >= desk.neighbours[item].count {
                res = neighbours
            } else {
                for _ in 0..<infectionFactor {
                    res.append(neighbours.remove(at: Int.random(in: 0..<neighbours.count)))
                }
            }
            taskManagerQueue.async { [unowned self] in
                for newInd in res {
                    if !desk.values[newInd] {
                        desk.values[newInd] = true
                        desk.sick += 1
                        desk.buf.append(newInd)
                    }
                }
                taskManagerQueueKey -= 1
            }
        }
    }
    
    
    private final class Desk: DeskState {
        let count: Int
        var sick: Int = 0
        var columnsCount: Int?
        var values: [Bool]
        var buf: [Int] = []
        var neighbours: [Set<Int>] = []
        
        init(count: Int) {
            self.count = count
            self.values = .init(repeating: false, count: count)
            for _ in 0..<count {
                neighbours.append([])
            }
        }
    }
    
}
