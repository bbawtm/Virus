//
//  DeskVC.swift
//  Virus
//
//  Created by Vadim Popov on 07.05.2023.
//

import UIKit


final class DeskVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var currentDesk: DeskState?
    
    private var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        view.register(UINib(nibName: "DeskCollectionCell", bundle: .main), forCellWithReuseIdentifier: "DeskCell")
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public func linkDesk(_ desk: DeskState) {
        currentDesk = desk
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    // MARK: - Collection View Settings
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentDesk else { fatalError("No Desk State provided for the Collection View") }
        print(currentDesk.count)
        return currentDesk.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let currentDesk else { fatalError("No Desk State provided for the Collection View") }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeskCell", for: indexPath) as? DeskCellView else {
            fatalError("DeskCell doesn't comform to expected type")
        }
        print(indexPath.item)
        cell.setType(isRed: currentDesk.values[indexPath.item])
        return cell
    }
    
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath
//    ) -> CGSize {
//        guard let currentDesk else { fatalError("No Desk State provided for the Collection View") }
//        return CGSize(width: sqrt(Double(currentDesk.count)) - 1, height: sqrt(Double(currentDesk.count)) - 1)
//    }
    
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        insetForSectionAt section: Int
//    ) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
//    }
    
}


extension UICollectionView {

    func drawLine(
        from: IndexPath,
        to: IndexPath,
        lineWidth: CGFloat = 2,
        strokeColor: UIColor = .red
    ) {
        guard let fromPoint = cellForItem(at: from)?.center,
              let toPoint = cellForItem(at: to)?.center
        else { return }

        let path = UIBezierPath()

        path.move(to: convert(fromPoint, to: self))
        path.addLine(to: convert(toPoint, to: self))

        let layer = CAShapeLayer()

        layer.path = path.cgPath
        layer.lineWidth = lineWidth
        layer.strokeColor = strokeColor.cgColor

        self.layer.addSublayer(layer)
    }
    
}
