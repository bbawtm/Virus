//
//  MainVC.swift
//  Virus
//
//  Created by Vadim Popov on 07.05.2023.
//

import UIKit


final class MainVC: UIViewController {
    
    private lazy var groupSizeField = {
        let field = CustomTextFieldView(label: "Group size", placeholder: "Enter positive integer value")
        field.setChecker(checker: groupSizeChecker)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    private lazy var infectionFactorField = {
        let field = CustomTextFieldView(label: "Infection factor", placeholder: "Enter integer value from 0...8")
        field.setChecker(checker: infectionFactorChecker)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    private lazy var timeIntervalField = {
        let field = CustomTextFieldView(label: "Time interval", placeholder: "Enter positive float value (seconds)")
        field.setChecker(checker: floatChecker)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    private lazy var startButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(
            "Start",
            attributes: AttributeContainer([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)])
        )
        config.cornerStyle = .capsule
        config.contentInsets = .init(top: 8, leading: 24, bottom: 8, trailing: 24)
        let action = UIAction(handler: { [self] _ in
            if groupSizeField.isCorrect && infectionFactorField.isCorrect && timeIntervalField.isCorrect {
//                if Int(groupSizeField.getValue()) ?? 0 > 1000 {
//                    let alert = UIAlertController(title: "Are you sure?", message: "Perhaps it is worth reducing the 'Group size' to at least 1000.", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//                    present(alert, animated: true)
//                } else {
                    coordinator.getReference(for: Router.self).switchToDesk(
                        groupSizeField.getValue(),
                        infectionFactorField.getValue(),
                        timeIntervalField.getValue()
                    )
//                }
            } else {
                groupSizeChecker(groupSizeField)
                infectionFactorChecker(infectionFactorField)
                floatChecker(timeIntervalField)
            }
        })
        let btn = UIButton(configuration: config, primaryAction: action)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let groupSizeChecker: (CustomTextFieldView) -> Void = { field in
        if let num = Int(field.getValue()), num > 0 {
            field.hideError()
        } else {
            field.showError()
        }
    }
    private let infectionFactorChecker: (CustomTextFieldView) -> Void = { field in
        if let num = Int(field.getValue()), num >= 0 && num <= 8 {
            field.hideError()
        } else {
            field.showError()
        }
    }
    private let floatChecker: (CustomTextFieldView) -> Void = { field in
        if let num = Float(field.getValue()), num > 0 {
            field.hideError()
        } else {
            field.showError()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(groupSizeField)
        view.addSubview(infectionFactorField)
        view.addSubview(timeIntervalField)
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            groupSizeField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            groupSizeField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            groupSizeField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            
            infectionFactorField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            infectionFactorField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            infectionFactorField.topAnchor.constraint(equalTo: groupSizeField.bottomAnchor, constant: 30),
            
            timeIntervalField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            timeIntervalField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            timeIntervalField.topAnchor.constraint(equalTo: infectionFactorField.bottomAnchor, constant: 30),
            
            startButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
        ])
    }
    
}
