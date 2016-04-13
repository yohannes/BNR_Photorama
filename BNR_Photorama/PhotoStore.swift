//
//  PhotoStore.swift
//  BNR_Photorama
//
//  Created by Yohannes Wijaya on 4/12/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

enum ImageResult {
    case Success(UIImage)
    case Failure(ErrorType)
}

enum PhotoError: ErrorType {
    case ImageCreationError
}

class PhotoStore {
    
    // MARK: - Stored Properties
    
    let urlSession: NSURLSession = {
        let defaultSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: defaultSessionConfiguration)
    }()
    
    // MARK: - local Methods
    
    func fetchRecentPhotos(completion completion: (PhotosResult) -> Void) {
        guard let validURL = FlickrAPI.getRecentPhotosURL() else { return }
        let urlRequest = NSURLRequest(URL: validURL)
        // transfer request to the server
        let URlSessionDataTask = self.urlSession.dataTaskWithRequest(urlRequest) { (data, urlResponse, error) -> Void in
            let result = self.processRecentPhotosRequest(data: data, error: error)
            completion(result)
        }
        URlSessionDataTask.resume()
    }
    
    func fetchImageForPhoto(photo: Photo, completion: (ImageResult) -> Void) {
        let photoURL = photo.remoteURL
        let URLRequest = NSURLRequest(URL: photoURL)
        
        let URLSessionDataTask = self.urlSession.dataTaskWithRequest(URLRequest) { (data, urlResponse, error) -> Void in
            let result = self.processImageRequest(data: data, error: error)
            if case let .Success(image) = result {
                photo.image = image
            }
            completion(result)
        }
        URLSessionDataTask.resume()
    }
    
    func processRecentPhotosRequest(data data: NSData?, error: NSError?) -> PhotosResult {
        guard let validJSONData = data else {
            return PhotosResult.Failure(error!)
        }
        return FlickrAPI.getPhotosFromJSONData(validJSONData)
    }
    
    func processImageRequest(data data: NSData?, error: NSError?) -> ImageResult {
        guard let
            imageData = data,
            image = UIImage(data: imageData) else {
                return data == nil ? ImageResult.Failure(error!) : .Failure(PhotoError.ImageCreationError)
        }
        return .Success(image)
    }
}