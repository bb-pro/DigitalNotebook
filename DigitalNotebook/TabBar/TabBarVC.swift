//
//  TabBarVC.swift
//  DigitalNotebook
//
//  Created by Developer on 23/05/25.
//

import UIKit

class TabBarVC: UITabBarController {
    let mainVCStoryboard = UIStoryboard(name: "Main", bundle: .main)
    let tabBarAppearance = UITabBarAppearance()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setTabBarAppearance()
        self.selectedIndex = 0
    }
    
    private func setTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Set text + icon colors here
        let unselectedColor = UIColor(.unselected)
        let selectedColor = UIColor(.selected)
        
        appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
        
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]

        // Background
        appearance.backgroundColor = UIColor(red: 12/255, green: 12/255, blue: 13/255, alpha: 1.0)

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        addTabBarTopOverlay()
    }
    
    private func setupTabBar() {
        let firstVC = mainVCStoryboard.instantiateViewController(withIdentifier: "NotesVC") as! NotesVC
        firstVC.tabIndex = 0
        firstVC.tabBarItem = UITabBarItem(
            title: "Notes",
            image: UIImage(named: "noteTab")!.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "noteTab")!.withRenderingMode(.alwaysTemplate))
        let firstNavVC = UINavigationController(rootViewController: firstVC)
        firstNavVC.navigationBar.isHidden = true
        
        let secondVC = mainVCStoryboard.instantiateViewController(withIdentifier: "NotesVC") as! NotesVC
        secondVC.tabIndex = 1
        secondVC.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(named: "favoritesTab")!.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "favoritesTab")!.withRenderingMode(.alwaysTemplate))
        let secondNavVC = UINavigationController(rootViewController: secondVC)
        secondNavVC.navigationBar.isHidden = true

        let thirdVC = mainVCStoryboard.instantiateViewController(withIdentifier: "NotesVC") as! NotesVC
        thirdVC.tabIndex = 2
        thirdVC.tabBarItem = UITabBarItem(
            title: "Security", 
            image: UIImage(named: "securityTab")!.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "securityTab")?.withRenderingMode(.alwaysTemplate))
        let thirdNavVC = UINavigationController(rootViewController: thirdVC)
        thirdNavVC.navigationBar.isHidden = true

        let fourthVC = mainVCStoryboard.instantiateViewController(withIdentifier: "SettingsVC")
        fourthVC.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(named: "settingsTab")!.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "settingsTab")?.withRenderingMode(.alwaysTemplate))
        let fourthNavVC = UINavigationController(rootViewController: fourthVC)
        fourthNavVC.navigationBar.isHidden = true

        self.viewControllers = [firstVC, secondVC, thirdVC, fourthVC]
    }
    
    private func addTabBarTopOverlay() {
        // Remove existing overlays (optional safety)
        tabBar.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }

        // Create overlay view
        let overlayHeight: CGFloat = 2
        let overlay = UIView()
        overlay.tag = 999
        overlay.backgroundColor = UIColor(resource: .unselected)
        
        overlay.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: tabBar.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            overlay.heightAnchor.constraint(equalToConstant: overlayHeight)
        ])
    }
}


