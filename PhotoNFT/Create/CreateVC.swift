//
//  CreateVC.swift
//  PhotoNFT
//
//  Created by Kennan Mell on 6/17/23.
//

import UIKit
import PhotosUI

class CreateVC: UIViewController {
    
    // MARK: Properties
    
    private var createView: CreateView {
        view as! CreateView
    }
    
    // MARK: UIViewController
    
    override func loadView() {
        view = CreateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = Strings.createTab
        createView.imagePicker.addTarget(self, action: #selector(pickerTapped), for: .touchUpInside)
        createView.previewButton.addTarget(self, action: #selector(previewTapped), for: .touchUpInside)
    }
    
    // MARK: Callbacks
    
    @objc private func pickerTapped() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let pickerVC = PHPickerViewController(configuration: configuration)
        pickerVC.delegate = self
        present(pickerVC, animated: true)
    }
    
    @objc private func previewTapped() {
        if let image = createView.imagePicker.imageView?.image {
            navigationController?.pushViewController(CreatePreviewVC(image: image), animated: true)
        }
    }
}

// MARK: PHPickerViewControllerDelegate
extension CreateVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {
        assert(results.count <= 1)
        guard let result = results.first else {
            dismiss(animated: true)
            return
        }
        result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
            DispatchQueue.main.async {
                if let image = object as? UIImage {
                    self.createView.imagePicker.setImage(image, for: .normal)
                    self.dismiss(animated: true)
                } else {
                    self.dismiss(animated: true) {
                        let message = error?.localizedDescription ?? Strings.genericError
                        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: Strings.ok, style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
}
