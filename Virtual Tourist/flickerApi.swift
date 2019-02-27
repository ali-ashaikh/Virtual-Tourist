//
//  flickerApi.swift
//  Virtual Tourist
//
//  Created by Ali Ashaikh on 2019-02-16.
//  Copyright © 2019 Ali Ashaikh. All rights reserved.
//

import Foundation


class flickerApi {
    var finalUrl:String = "No URl Yet"

    func searchByLatLon(lat: Double, lon: Double, completion: @escaping (String?, String?) -> Void){
        let methodParameters = [
                flickerConstants.FlickrParameterKeys.Method: flickerConstants.FlickrParameterValues.SearchMethod,
                flickerConstants.FlickrParameterKeys.APIKey: flickerConstants.FlickrParameterValues.APIKey,
                flickerConstants.FlickrParameterKeys.BoundingBox: bboxString(lat: lat,lon: lon),
                flickerConstants.FlickrParameterKeys.SafeSearch: flickerConstants.FlickrParameterValues.UseSafeSearch,
                flickerConstants.FlickrParameterKeys.Extras: flickerConstants.FlickrParameterValues.MediumURL,
                flickerConstants.FlickrParameterKeys.Format: flickerConstants.FlickrParameterValues.ResponseFormat,
                flickerConstants.FlickrParameterKeys.NoJSONCallback: flickerConstants.FlickrParameterValues.DisableJSONCallback
            ]
        
                    let pageLimit = min(1, 10)
                    let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1

        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[flickerConstants.FlickrParameterKeys.Page] = String(randomPage)
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String : AnyObject]))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            
            guard let photosDictionary = parsedResult[flickerConstants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(flickerConstants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            guard let photosArray = photosDictionary[flickerConstants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(flickerConstants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                displayError("No Photos Found. Search Again.")
                return
            } else {
                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                
                let imageUrlString = (photoDictionary[flickerConstants.FlickrResponseKeys.MediumURL] as? String)!
                if imageUrlString != "" {
                    self.finalUrl = imageUrlString
                }
                else{
                    print("No Key found for location image")
                }
            }
            
            DispatchQueue.main.async {
                completion(self.finalUrl, error as! String?)
            }
        }
        
        // start the task!
        task.resume()
        

    }
    
    
private func bboxString(lat: Double, lon: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let latitude = lat
        let longitude = lon
        let minimumLon = max(longitude - flickerConstants.Flickr.SearchBBoxHalfWidth, flickerConstants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - flickerConstants.Flickr.SearchBBoxHalfHeight, flickerConstants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + flickerConstants.Flickr.SearchBBoxHalfWidth, flickerConstants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + flickerConstants.Flickr.SearchBBoxHalfHeight, flickerConstants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    
    }
    
    
//       
    
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = flickerConstants.Flickr.APIScheme
        components.host = flickerConstants.Flickr.APIHost
        components.path = flickerConstants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    class func sharedInstance() -> flickerApi {
        struct Singleton {
            static var sharedInstance = flickerApi()
        }
        return Singleton.sharedInstance
    }



}
