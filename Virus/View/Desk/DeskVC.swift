//
//  DeskVC.swift
//  Virus
//
//  Created by Vadim Popov on 07.05.2023.
//

import UIKit


final class DeskVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    private var currentDesk: DeskState?
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView(frame: view.bounds)
        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = max(sqrt(Double(currentDesk?.count ?? 0)), 1)
        scroll.delegate = self
        return scroll
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        view.register(UINib(nibName: "DeskCollectionCell", bundle: .main), forCellWithReuseIdentifier: "DeskCell")
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statView: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public func linkDesk(_ desk: DeskState) {
        currentDesk = desk
        statView.text = "0:\(currentDesk?.count ?? 1) (0%)"
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
        ])
        
        navigationItem.titleView = statView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.setZoomScale(1, animated: false)
        currentDesk = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        coordinator.getReference(for: VirusEngine.self).connectUI(
            columnsCount: getNumberOfCellsInRow()
        )
    }
    
    public func reloadAll() {
        let buf = currentDesk?.buf ?? []
        for ind in buf {
            if let cell = collectionView.cellForItem(at: IndexPath(item: ind, section: 0)) as? DeskCellView {
                cell.setType(isRed: true)
            }
        }
        refreshStat()
    }
    
    private func refreshStat() {
        guard let sick = currentDesk?.sick,
              let count = currentDesk?.count
        else { return }
        
        let healthy = count - sick
        let percent = Int(100.0 * Double(sick) / Double(sick + healthy))
        statView.text = "\(sick):\(healthy) (\(percent)%)"
    }
    
    // MARK: - Collection View Settings
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentDesk else { fatalError("No Desk State provided for the Collection View") }
        return currentDesk.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let currentDesk else { fatalError("No Desk State provided for the Collection View") }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeskCell", for: indexPath) as? DeskCellView else {
            fatalError("DeskCell doesn't comform to expected type")
        }
        cell.setType(isRed: currentDesk.values[indexPath.item])
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let currentDesk else { fatalError("No Desk State provided for the Collection View") }
        let sqrtNum = sqrt(Double(currentDesk.count))
        let eachSize = Double(collectionView.frame.width - 16) / sqrtNum
        return CGSize(width: eachSize, height: eachSize)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    private func getNumberOfCellsInRow() -> Int {
        var ind = 0
        let firstY = collectionView.cellForItem(at: IndexPath(item: 0, section: 0))?.frame.origin.y
        while collectionView.cellForItem(at: IndexPath(item: ind, section: 0))?.frame.origin.y == firstY {
            ind += 1
        }
        return ind
    }
    
    // MARK: - Touch handling
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DeskCellView else { return }
        coordinator.getReference(for: VirusEngine.self).addInfected(indexPath.item)
        cell.setType(isRed: true)
        refreshStat()
    }
    
    // MARK: - Zooming
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == self.scrollView {
            return collectionView
        }
        return nil
    }

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
