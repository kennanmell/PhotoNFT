//
//  ImagePageVC.swift
//  PhotoNFT
//
//  Created by Kennan Mell on 6/17/23.
//

import UIKit

class ImagePageVC: UIPageViewController {
    
    // MARK: Properties
    
    private let imagesModel: ImagesModel = ImagesModelImpl.instance
    private let initialIndex: Int
    private var vcs = [UIViewController]()
    var dismissBlock: (() -> Void)?
    var setAlphaBlock: ((CGFloat) -> Void)?
    private(set) var transform = CGAffineTransform.identity
    
    // MARK: Initialization
    
    init(initialIndex: Int) {
        self.initialIndex = initialIndex
        var vcs = [UIViewController]()
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        for image in imagesModel.imagesSubject.value {
            vcs.append(ImageVC(image: image, delegate: self))
        }
        self.vcs = vcs
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setViewControllers([vcs[initialIndex]], direction: .forward, animated: false)
        
        navigationItem.leftBarButtonItem
            = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                              style: .plain,
                              target: self,
                              action: #selector(self.closeTapped))
    }
    
    // MARK: Callbacks
    
    @objc private func closeTapped() {
        dismissBlock?()
    }
}

// MARK: UIPageViewControllerDataSource
extension ImagePageVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard viewController != vcs.first,
              let index = vcs.firstIndex(of: viewController) else {
            return nil
        }
        return vcs[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard viewController != vcs.last,
              let index = vcs.firstIndex(of: viewController) else {
            return nil
        }
        return vcs[index + 1]
    }
}

// MARK: ImageVCDelegate
extension ImagePageVC: ImageVCDelegate {
    func panned(transform: CGAffineTransform, alpha: CGFloat, ended: Bool) {
        self.transform = transform
        setAlphaBlock?(alpha)
        if ended {
            dismissBlock?()
        }
    }
}
