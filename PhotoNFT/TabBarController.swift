//
//  TabBarController.swift
//  PhotoNFT
//
//  Created by Kennan Mell on 6/17/23.
//

import UIKit

enum TabType: Int {
    case gallery, create, menu
    
    var imageSystemName: String {
        switch self {
        case .gallery: return "photo"
        case .create: return "plus"
        case .menu: return "ellipsis.circle"
        }
    }
    
    var title: String {
        switch self {
        case .gallery: return Strings.galleryTab
        case .create: return Strings.createTab
        case .menu: return Strings.menuTab
        }
    }
    
    var tabBarItem: UITabBarItem {
        return UITabBarItem(title: title,
                            image: UIImage(systemName: imageSystemName),
                            tag: rawValue)
    }
}

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        let galleryVC = GalleryVC()
        galleryVC.tabBarItem = TabType.gallery.tabBarItem
        let createVC = UINavigationController(rootViewController: CreateVC())
        createVC.tabBarItem = TabType.create.tabBarItem
        let menuVC = UINavigationController(rootViewController: MenuVC())
        menuVC.tabBarItem = TabType.menu.tabBarItem
        viewControllers = [galleryVC, createVC, menuVC]
    }
}
