//
//  RequestAction.swift
//  HitssTest
//
//  Created by Sergio Acosta Vega on 9/6/21.
//

import Foundation

class RequestAction {
    
    var path: String
    var method: Method!
    var body: Encodable?
    var components: [URLQueryItem] = [URLQueryItem]()
    
    init(endpoint: Endpoint, body: Encodable? = nil) {
        path = endpoint.rawValue
        self.method = endpoint.method
        self.body = body
        self.components = endpoint.components
    }
    
    func getBodyInData() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let encodableBody = body {
            return encodableBody.toJSONData()
        }
        
        return nil
    }
}

extension Encodable {
    func toJSONData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        
        guard let dataSerialized = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let dictionary =  dataSerialized as? [String: Any] else {
                return [:]
        }
        
        return dictionary
    }
}

enum Method: String {
    case GET
    case POST
    case PUT
    case DELETE
    
    var rawValue: String {
        switch self {
        case .GET: return "GET"
        case .POST: return "POST"
        case .PUT: return "PUT"
        case .DELETE: return "DELETE"
        }
    }
}

enum Endpoint {
    
    case topRated(Int)
    
    var method: Method {
        switch self {
        case .topRated: return .GET
        }
    }
    
    var rawValue: String {
        switch self {
        case .topRated: return "/movie/top_rated"
        }
    }
    
    var components: [URLQueryItem] {
        switch self {
        case .topRated(let page): return [URLQueryItem(name: "page", value: "\(page)")]
        }
    }
}
