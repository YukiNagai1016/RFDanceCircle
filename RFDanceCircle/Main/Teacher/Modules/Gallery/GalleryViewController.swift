//
//  GalleryViewController.swift
//  R&FDanceCircleApp
//
//  Created by YukiNagai on 2020/01/30.
//  Copyright © 2020 YukiNagai. All rights reserved.
//

import Foundation
import UIKit

class GalleryViewController: UIViewController, NibBased, ViewModelBased {
    
    // MARK: Properties
    
    var viewModel: GalleryViewModel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private let layout = CollectionViewPagingLayout()
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    // MARK: Event listener
    
    @IBAction private func onBackTouched() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onNextTouched() {
        layout.goToNextPage()
    }
    
    @IBAction private func onPreviousTouched() {
        layout.goToPrevPage()
    }
    
    
    // MARK: Private functions
    
    private func configureViews() {
        view.backgroundColor = .black
        view.clipsToBounds = true
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        collectionView.register(PhotoCollectionViewCell.self)
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        layout.numberOfVisibleItems = 10
        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
    }
    
}

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.itemViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemViewModel = viewModel.itemViewModels[indexPath.row]
        let cell: PhotoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.viewModel = itemViewModel
        return cell
    }

}

