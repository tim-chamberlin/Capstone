//
//  AppearanceController.swift
//  A-Side
//
//  Created by Tim on 9/3/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation
import UIKit

struct AppearanceController {
    
    static func initializeAppearance() {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        UIBarButtonItem.appearance().tintColor = UIColor.offWhiteColor()
        
//        UINavigationBar.appearance().backgroundColor = UIColor.lightCharcoalColor()
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.navigationBarFont(), NSForegroundColorAttributeName: UIColor.offWhiteColor()]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.barButtonItemBold(), NSForegroundColorAttributeName: UIColor.offWhiteColor()], forState: .Normal)
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.smallLabelFont(), NSForegroundColorAttributeName: UIColor.goldColor()], forState: .Normal)
        UISegmentedControl.appearance().tintColor = UIColor.goldColor()
        
        UITableView.appearance().backgroundColor = UIColor.darkCharcoalColor()
        UITableView.appearance().separatorColor = UIColor.lightCharcoalColor()
        UITableViewCell.appearance().selectionStyle = UITableViewCellSelectionStyle.Blue
        UITableViewCell.appearance().backgroundColor = UIColor.darkCharcoalColor()
    }
}

extension UIColor {
    
    static func charcoalColor() -> UIColor {
        return UIColor(red: 0.153, green: 0.153, blue: 0.153, alpha: 1.00)
    }
    
    static func darkCharcoalColor() -> UIColor  {
        return UIColor(red: 0.106, green: 0.106, blue: 0.106, alpha: 1.00)
    }
    
    static func lightCharcoalColor() -> UIColor {
        return UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.00)
    }
    
    static func offWhiteColor() -> UIColor {
        return UIColor(red: 0.961, green: 0.957, blue: 0.961, alpha: 1.00)
    }
    
    static func deepBlueColor() -> UIColor {
        return UIColor(red: 0.000, green: 0.498, blue: 0.980, alpha: 1.00)
    }
    
    static func goldColor() -> UIColor {
        return UIColor(red: 1.000, green: 0.859, blue: 0.102, alpha: 1.00)
    }
    
}

extension UIFont {
    
    static func smallLabelFont() -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 12)!
    }
    
    static func mediumLabelFont() -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 15)!
    }
    
    static func largeLabelFont() -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 17)!
    }
    
    static func navigationBarFont() -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 16)!
    }
    
    static func barButtonItemBold() -> UIFont {
        return UIFont(name: "AvenirNext-Medium", size: 16)!
    }
    
}








