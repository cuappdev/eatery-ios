//
//  EateriesViewController.swift
//  Eatery
//
//  Created by William Ma on 3/12/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class EateriesViewController: UIViewController {

    private struct EateriesBySection {

        let favorites: [Eatery]
        let open: [Eatery]
        let closed: [Eatery]
        
        let grouped: [[Eatery]]

        init(favorites: [Eatery], open: [Eatery], closed: [Eatery]) {
            self.favorites = favorites
            self.open = open
            self.closed = closed

            self.grouped = [favorites, open, closed]
        }

    }

    private enum State {

        case eateries(EateriesBySection)
        case loading
        case failedToLoad(Error?)

    }

    private enum CellIdentifier: String {

        case eatery

    }

    private enum SupplementaryViewIdentifier: String {

        case header

    }

    private var state: State = .loading

    private let collectionView = UICollectionView()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EateryCollectionViewCell.self,
                                forCellWithReuseIdentifier: CellIdentifier.eatery.rawValue)
        collectionView.register(EateriesCollectionViewHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: SupplementaryViewIdentifier.header.rawValue)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func eateries(in section: Int) -> [Eatery] {
        guard case let .eateries(eateriesBySection) = state else {
            return []
        }

        let withEmptySectionsRemoved = eateriesBySection.grouped.filter { !$0.isEmpty }
        return withEmptySectionsRemoved[section]
    }

    private func eatery(for indexPath: IndexPath) -> Eatery {
        return eateries(in: indexPath.section)[indexPath.row]
    }

}

extension EateriesViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard case let .eateries(eateriesBySection) = state else {
            return 0
        }

        return eateriesBySection.grouped.filter { !$0.isEmpty }.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eateries(in: section).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EateryCollectionViewCell
        let eatery = self.eatery(for: indexPath)
        cell.eatery = eatery
        cell.userLocation = userLocation


    }

}

extension EateriesViewController: UICollectionViewDelegate {

}
