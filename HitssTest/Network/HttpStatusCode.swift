//
//  RequestAction.swift
//  HitssTest
//
//  Created by Sergio Acosta Vega on 9/6/21.
//

import Foundation

public enum HttpStatusCode: Int {
    
    /// No internet
    case noInternet         = 0
    
    /// OK
    case success            = 200
    
    /// CREATED
    case created            = 201
    
    case parseError         = 205
    /// Unauthorized
    case unAuthorized       = 401
    
    /// Not Found
    case notFound           = 404
    
    // Upgrade required (It means that the current application must be updated immediately)
    case upgradeRequired    = 412
    
    /// Some server error
    case serverError        = 500
    
    /// Unknown (unexpeceted) error code will be marked as 501
    case unknownError       = 501
    
    /// Fail-safe initialization
    public init(rawValue: Int) {
        switch rawValue {
        case 0:     self = .noInternet
        case 200:   self = .success
        case 201:   self = .created
        case 401:   self = .unAuthorized
        case 404:   self = .notFound
        case 500:   self = .serverError
            
        default: self = .unknownError
        }
    }
}
