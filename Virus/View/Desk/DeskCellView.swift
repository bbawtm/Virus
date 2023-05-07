//
//  DeskCellView.swift
//  Virus
//
//  Created by Vadim Popov on 07.05.2023.
//

import UIKit


final class DeskCellView: UICollectionViewCell {
    
    @IBOutlet weak var circle: UIView!
    
    public func setType(isRed: Bool) {
        circle.layer.cornerRadius = 8
        circle.layer.borderColor = UIColor.label.withAlphaComponent(0.75).cgColor
        circle.layer.borderWidth = 1
        circle.backgroundColor = isRed ? .systemRed : .systemFill
    }
    
}
