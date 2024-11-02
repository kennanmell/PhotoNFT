//
//  CreatePreviewVC.swift
//  PhotoNFT
//
//  Created by Kennan Mell on 6/17/23.
//

import UIKit

class CreatePreviewVC: UIViewController {
    
    // MARK: Properties
    
    private let imagesModel: ImagesModel = ImagesModelImpl.instance
    private let imageView = UIImageView()
    private let image: UIImage
    private let createButton = UIButton(configuration: UIButton.Configuration.filled())
    
    // MARK: Initialization
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        view.addSubview(imageView)
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    
    // MARK: Callbacks
    
    @objc private func createTapped() {
        imagesModel.insert(image: image)
        let alert = UIAlertController(title: nil, message: Strings.createSuccess, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.ok, style: .default, handler: { _ in
            self.dismiss(animated: true)
        }))
    }
}

