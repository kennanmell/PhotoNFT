//
//  ImagesModel.swift
//  PhotoNFT
//
//  Created by Kennan Mell on 6/17/23.
//

import UIKit
import Combine

protocol ImagesModel {
    var imagesSubject: CurrentValueSubject<[UIImage], Never> { get }
    var selectedIndexSubject: CurrentValueSubject<Int?, Never> { get }
    func insert(image: UIImage)
}

class ImagesModelImpl: ImagesModel {
    let selectedIndexSubject = CurrentValueSubject<Int?, Never>(nil)
    
    static let instance = ImagesModelImpl()

    // TODO: Combine with @Published
    private(set) var imagesSubject = CurrentValueSubject<[UIImage], Never>([UIImage(named: "placeholder")!])
    //private(set) var imagesSubject = CurrentValueSubject<[UIImage], Never>([UIImage]())
    // TODO: Remove the placeholder when ready
    private var images = [UIImage(named: "placeholder")!] {
    //private var images = [UIImage]() {
        didSet {
            imagesSubject.send(images)
        }
    }
    
    func insert(image: UIImage) {
        images.append(image)
    }
}
