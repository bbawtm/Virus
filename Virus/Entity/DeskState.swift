//
//  DeskState.swift
//  Virus
//
//  Created by Vadim Popov on 07.05.2023.
//

import UIKit


protocol DeskState {
    var count: Int { get }
    var values: [Bool] { get }
}
