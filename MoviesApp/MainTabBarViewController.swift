//
//  ViewController.swift
//  MoviesApp
//
//  Created by Niyazov Makhmujan on 26.03.2023.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
    }
    
    private func setupViews() {
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        let upcomingVC = UINavigationController(rootViewController: UpcomingViewController())
        let downloadVC = UINavigationController(rootViewController: DownloadsViewController())
        
        homeVC.tabBarItem.image = UIImage(systemName: "house")
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        upcomingVC.tabBarItem.image = UIImage(systemName: "play.circle")
        downloadVC.tabBarItem.image = UIImage(systemName: "arrow.down.to.line")
        
        homeVC.title = "Home"
        searchVC.title = "Top Search"
        upcomingVC.title = "Coming Soon"
        downloadVC.title = "Downloads"
        
        tabBar.tintColor = .label
        
        setViewControllers([homeVC, searchVC, upcomingVC, downloadVC], animated: true)
    }


}

