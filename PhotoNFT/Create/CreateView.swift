//
//  CreateView.swift
//  PhotoNFT
//
//  Created by Kennan Mell on 6/17/23.
//

import UIKit

class CreateView: UIView {
    let imagePicker = UIButton()
    let previewButton = UIButton(configuration: UIButton.Configuration.filled())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imagePicker.setImage(UIImage(named: "placeholder")?.withRenderingMode(.alwaysTemplate), for: .normal)
        imagePicker.tintColor = .secondarySystemBackground
        imagePicker.imageView?.contentMode = .scaleAspectFit
        addSubview(imagePicker)
        
        previewButton.setTitle(Strings.preview, for: .normal)
        addSubview(previewButton)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        let imagePickerWidth = frame.width * 0.8
        let imagePickerHeight = imagePickerWidth * (imagePicker.imageView?.image?.size.height ?? 1) / (imagePicker.imageView?.image?.size.width ?? 1)
        imagePicker.frame = CGRect(x: (frame.width - imagePickerWidth) / 2,
                                   y: safeAreaInsets.top + 20,
                                   width: imagePickerWidth,
                                   height: imagePickerHeight)
        
        let previewButtonWidth: CGFloat = frame.width * 0.8
        previewButton.frame = CGRect(x: (frame.width - previewButtonWidth) / 2,
                                     y: frame.height - 200,
                                     width: previewButtonWidth,
                                     height: 50)
    }
}
