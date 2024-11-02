//
//  GalleryVC.swift
//  PhotoNFT
//
//  Created by Kennan Mell on 6/17/23.
//

import UIKit
import Combine

class GalleryCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        imageView.frame = bounds
    }
}

class GalleryVC: UICollectionViewController {
    
    // MARK: Properties
    
    private enum Constants {
        static let collectionViewSpacing: CGFloat = 2
        static let reuseIdentifier = "GalleryCollectionViewCell"
    }
    
    private let imagesModel: ImagesModel = ImagesModelImpl.instance
    private var imagesCancellable: AnyCancellable?
    private var selectionCancellable: AnyCancellable?
    private var hiddenIndex: Int?
    private let animationImageView = UIImageView()
    private let overlayView = UIView()
    private let emptyStateView = UILabel()
    
    // MARK: Initialization
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = Strings.galleryTab
        collectionView.register(
            GalleryCollectionViewCell.self,
            forCellWithReuseIdentifier: Constants.reuseIdentifier)
        animationImageView.contentMode = .scaleAspectFill
        animationImageView.clipsToBounds = true
        collectionView.addSubview(overlayView)
        collectionView.addSubview(animationImageView)
        collectionView.alwaysBounceVertical = true
        
        emptyStateView.textAlignment = .center
        emptyStateView.text = Strings.emptyGalleryText
        emptyStateView.textColor = .label
        emptyStateView.numberOfLines = 0
        view.addSubview(emptyStateView)
        
        imagesCancellable = imagesModel.imagesSubject.sink { [weak self] images in
            self?.emptyStateView.isHidden = !images.isEmpty
            self?.collectionView.reloadData()
        }
        selectionCancellable = imagesModel.selectedIndexSubject.sink(receiveValue: { [weak self] index in
            if let hiddenIndex = self?.hiddenIndex {
                self?.collectionView.cellForItem(
                    at: IndexPath(row: hiddenIndex, section: 0))?.isHidden = false
            }
            if let index {
                self?.collectionView.cellForItem(
                    at: IndexPath(row: index, section: 0))?.isHidden = true
            }
            self?.hiddenIndex = index
        })
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyStateView.frame = CGRect(x: 5,
                                      y: 0,
                                      width: view.bounds.width - 10,
                                      height: view.bounds.height)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return imagesModel.imagesSubject.value.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifier,
                                 for: indexPath) as? GalleryCollectionViewCell else {
            assertionFailure()
            return UICollectionViewCell()
        }
        cell.imageView.image = imagesModel.imagesSubject.value[indexPath.row]
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    private func expandedFrame(for image: UIImage) -> CGRect {
        var frame = view.bounds
        if frame.height > frame.width {
            frame.size.height = frame.width * image.size.height / image.size.width
            frame.origin.y = (view.bounds.height - frame.size.height) / 2
            frame.origin.y -= view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            if UIDevice.current.userInterfaceIdiom != .pad {
                // Not sure why this -5 is needed, but it ensures there's no jump in the
                // animation when the animationImageView is hidden.
                frame.origin.y -= 5
            }
        } else {
            frame.size.width = frame.height * image.size.width / image.size.height
            frame.origin.x = (view.bounds.width - frame.size.width) / 2
            frame.origin.x -= view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            if UIDevice.current.userInterfaceIdiom == .pad {
                // Not sure why this -24 is needed, but it ensures there's no jump in the
                // animation when the animationImageView is hidden.
                frame.origin.y -= 24
                frame.origin.x += 24
            }
        }
        return frame
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            assertionFailure()
            return
        }
        let image = imagesModel.imagesSubject.value[indexPath.row]
        animationImageView.image = image
        animationImageView.frame = cell.frame
        animationImageView.isHidden = false
        cell.isHidden = true
        let newFrame = expandedFrame(for: image)
        overlayView.frame = view.bounds
        overlayView.alpha = 1
        UIView.animate(withDuration: 0.2) {
            self.animationImageView.frame = newFrame
            self.tabBarController?.tabBar.alpha = 0
            self.overlayView.backgroundColor = .systemBackground
        } completion: { _ in
            let imagePageVC = ImagePageVC(initialIndex: indexPath.row)
            let navigationController = UINavigationController(rootViewController: imagePageVC)
            imagePageVC.setAlphaBlock = { alpha in
                self.overlayView.alpha = alpha
            }
            imagePageVC.dismissBlock = {
                let newIndex = self.hiddenIndex ?? indexPath.row
                let newCell = collectionView.cellForItem(
                    at: IndexPath(row: newIndex, section: 0)) ?? cell
                let startImage = self.imagesModel.imagesSubject.value[newIndex]
                self.animationImageView.image = startImage
                let startFrame = self.expandedFrame(for: startImage)
                self.animationImageView.frame = startFrame
                self.animationImageView.transform = imagePageVC.transform
                self.animationImageView.isHidden = false
                navigationController.willMove(toParent: nil)
                navigationController.view.removeFromSuperview()
                navigationController.removeFromParent()
                UIView.animate(withDuration: 0.2) {
                    self.animationImageView.transform = .identity
                    self.animationImageView.frame = newCell.frame
                    self.tabBarController?.tabBar.alpha = 1
                    self.overlayView.backgroundColor = .clear
                } completion: { _ in
                    self.animationImageView.isHidden = true
                    newCell.isHidden = false
                    self.overlayView.frame = .zero
                }
            }
            self.view.addSubview(navigationController.view)
            navigationController.view.frame = self.view.frame
            self.addChild(navigationController)
            navigationController.didMove(toParent: self)
            self.animationImageView.isHidden = true
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension GalleryVC: UICollectionViewDelegateFlowLayout {
    private var itemsPerRow: CGFloat {
        // TODO: Support iPad layout
        switch UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
        case .portrait, .portraitUpsideDown, .unknown, .none:
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 5
            } else {
                return 3
            }
        case .landscapeLeft, .landscapeRight:
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 7
            } else {
                return 5
            }
        @unknown default:
            assertionFailure()
            return 3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimension = collectionView.frame.width / itemsPerRow - Constants.collectionViewSpacing
        return CGSize(width: dimension, height: dimension)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.collectionViewSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.collectionViewSpacing
    }
}
