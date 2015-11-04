//
//  GroundKontrol.swift
//  GroundKontrol
//
//  Created by Khalid Mills on 11/4/15.
//  Copyright © 2015 iksnae. All rights reserved.
//

import Foundation

typealias GroundKontrolConfigFetchHandler = (configuration:[String:AnyObject]?, err:NSError?)->()
typealias GroundKontrolRegisterCallback = (success:Bool)->()

extension NSUserDefaults
{
    func registerDefaultsWithRequest(req:NSURLRequest, callback:GroundKontrolRegisterCallback?=nil){
        func fin(success:Bool){
            if let cb = callback {
                cb(success: success)
            }
        }
        fetchConfig(req) { (configuration:[String:AnyObject]?, err:NSError?) -> () in
            if let config = configuration {
                self.setValuesForKeysWithDictionary(config)
                self.synchronize()
                fin(true)
            }else{
                fin(false)
            }
        }
        
    }
    
    
    func registerDefaultsWithURL(url:NSURL, callback:GroundKontrolRegisterCallback?=nil){
        registerDefaultsWithRequest(NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 3),callback: callback)
    }
}



private func fetchConfig(req:NSURLRequest, handler:GroundKontrolConfigFetchHandler? = nil){
    NSURLSession.sharedSession().dataTaskWithRequest(req) { (data:NSData?, resp:NSURLResponse?, err:NSError?) -> Void in
        var config:[String:AnyObject]?
        var e:NSError? = err
        if err == nil {
            if let d = data {
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.MutableContainers)
                    if let dict = json as? [String:AnyObject] {
                        config = dict
                    }
                }catch{
                    let x = GroundControlErrorCode.FailedToParseConfiguration
                    e = NSError(domain:x.domain, code: 0, userInfo: [NSLocalizedDescriptionKey : x.errorMessage])
                }
            }else{
                let x = GroundControlErrorCode.NotDataReturned
                e = NSError(domain:x.domain, code: 0, userInfo: [NSLocalizedDescriptionKey : x.errorMessage])
            }
        }
        
        if let cb = handler{
            cb(configuration: config, err: e)
        }
        
    }.resume()
}

enum GroundControlErrorCode:Int{
    case FailedToParseConfiguration = 0
    case NotDataReturned = 1
    var errorMessage:String {
        switch self {
        case .FailedToParseConfiguration:
            return "Failed to parse configuration."
        case .NotDataReturned:
            return "No data returned."
        }
    }
    var domain:String {
        return "GroundKontrolError"
    }
}
