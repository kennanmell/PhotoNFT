//
//  ImageVC.swift
//  PhotoNFT
//
//  Created by Kennan Mell on 6/17/23.
//

import UIKit

protocol ImageVCDelegate: AnyObject {
    func panned(transform: CGAffineTransform, alpha: CGFloat, ended: Bool)
}

class ImageVC: UIViewController {
    
    // MARK: Properties
    
    private let imagesModel: ImagesModel = ImagesModelImpl.instance
    private lazy var imageView = UIImageView()
    private let image: UIImage
    private weak var delegate: ImageVCDelegate?
    private var translation = CGPoint(x: 0, y: 0)
    private var dismissing = false
    private var lastAlpha: CGFloat = 1

    // MARK: Initialization
    
    init(image: UIImage, delegate: ImageVCDelegate) {
        self.image = image
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let index = imagesModel.imagesSubject.value.firstIndex(of: image) {
            imagesModel.selectedIndexSubject.send(index)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    
    // MARK: Callbacks
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            let newTranslation = sender.translation(in: view)
            // This check prevents false positives.
            if abs(newTranslation.y - translation.y) > 10 {
                if newTranslation.y < 0 {
                    dismissing = newTranslation.y < translation.y
                } else {
                    dismissing = newTranslation.y > translation.y
                }
                translation = newTranslation
            }
            let scale = max(0.75, 1 - abs(newTranslation.y) / view.frame.height / 4)
            view.transform = CGAffineTransform(translationX: newTranslation.x, y: newTranslation.y)
                .scaledBy(x: scale, y: scale)
            lastAlpha = 1 - abs(newTranslation.y) / view.frame.height
            delegate?.panned(transform: view.transform,
                             alpha: lastAlpha,
                             ended: false)
        case .ended:
            if !dismissing {
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 1,
                               options: .curveEaseOut,
                               animations: {
                    self.view.transform = .identity
                }) { _ in
                    self.delegate?.panned(transform: self.view.transform,
                                          alpha: self.lastAlpha,
                                          ended: true)
                }
            } else {
                delegate?.panned(transform: view.transform, alpha: lastAlpha, ended: true)
            }
        default:
            break
        }
    }
}

