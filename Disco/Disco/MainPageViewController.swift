//
//  MainPageViewController.swift
//  A-Side
//
//  Created by Tim on 9/6/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class MainPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ContributingViewController")
    let secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StreamingViewController")
    
    var orderedViewControllers: [UIViewController] {
        return [firstVC, secondVC]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .charcoalColor()
        dataSource = self
        
        if let firstVC = orderedViewControllers.first {
            setViewControllers([firstVC], direction: .Forward, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIPageViewControllerDataSource Methods
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 && orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        guard orderedViewControllersCount != nextIndex && orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toTrackList" {
            guard let destinationVC = segue.destinationViewController as? TrackListViewController, contributingPlaylistListVC = firstVC as? ContributingViewController, tableView = contributingPlaylistListVC.contributingPlaylistsTableView.tableView, indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            destinationVC.playlist = contributingPlaylistListVC.contributingPlaylistsTableView.playlists[indexPath.row]
        }
    }

}
