//
//  ImageController.swift
//  Disco
//
//  Created by Tim on 9/2/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation

class ImageController {
    static func getImageFromURL(imageURL: NSURL, completion: (image: UIImage?, success: Bool) -> Void) {
        NetworkController.performRequestForURL(imageURL, httpMethod: NetworkController.HTTPMethod.Get) { (data, error) in
            guard let data = data else {
                completion(image: nil, success: false)
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(image: UIImage(data: data), success: true)
            })
        }
    }
    
    
    static func getImageFromURLWithResponse(imageURL: NSURL, completion: (image: UIImage?, response: NSURLResponse?, error: NSError?) -> Void) {
        NSURLSession.sharedSession().dataTaskWithURL(imageURL) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                guard let data = data, image = UIImage(data: data) else { return }
                completion(image: image, response: response, error: error)
            })
        }.resume()
    }
    
}