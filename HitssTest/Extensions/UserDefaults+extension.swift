//
//  UserDefaults+extension.swift
//  HitssTest
//
//  Created by Sergio Acosta Vega on 9/6/21.
//

import Foundation

extension UserDefaults {

    static func updateBase() -> (Bool, Int, PageHalf) {
        let lastTimeUpdated = "lastTimeUpdated"
        let lastPageRequested = "lastPageRequested"
        let lastHalfRequested = "lastHalfRequested"
        let maxPages = "maxPages"
     
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_MX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        
        if let lastStringDate = UserDefaults.standard.string(forKey: lastTimeUpdated),
           let lastDate = dateFormatter.date(from: lastStringDate),
           let lastHalfString = UserDefaults.standard.string(forKey: lastHalfRequested),
           let lastHalf = PageHalf(rawValue: lastHalfString) {
            
            let lastPage = UserDefaults.standard.integer(forKey: lastPageRequested)
            
            let currentDate = Date()
            
            if lastDate.addingTimeInterval(3600*24) < currentDate {
                UserDefaults.standard.set(dateFormatter.string(from: currentDate),
                                          forKey: lastTimeUpdated)
                
                if lastHalf == .top {
                    UserDefaults.standard.set(lastPage, forKey: lastPageRequested)
                    UserDefaults.standard.set(PageHalf.bottom.rawValue, forKey: lastHalfRequested)
                    UserDefaults.standard.synchronize()
                    return (true, lastPage, .bottom)
                } else {
                    
                    if lastPage == UserDefaults.standard.integer(forKey: maxPages) {
                        let date = Date()
                        UserDefaults.standard.set(dateFormatter.string(from: date), forKey: lastTimeUpdated)
                        UserDefaults.standard.set(1, forKey: lastPageRequested)
                        UserDefaults.standard.set(PageHalf.top.rawValue, forKey: lastHalfRequested)
                        UserDefaults.standard.synchronize()
                        return (true, 1, .top)
                    } else {
                        UserDefaults.standard.set(lastPage + 1, forKey: lastPageRequested)
                        UserDefaults.standard.set(PageHalf.top.rawValue, forKey: lastHalfRequested)
                        UserDefaults.standard.synchronize()
                        return (true, lastPage + 1, .top)
                    }
                }
                
            } else {
                return (false, 0, .top)
            }
            
        } else {
            let date = Date()
            UserDefaults.standard.set(dateFormatter.string(from: date), forKey: lastTimeUpdated)
            UserDefaults.standard.set(1, forKey: lastPageRequested)
            UserDefaults.standard.set(PageHalf.top.rawValue, forKey: lastHalfRequested)
            UserDefaults.standard.synchronize()
            return (true, 1, .top)
        }
    }
    
    static func maxPages(maxNumberPages: Int){
        let maxPages = "maxPages"
        UserDefaults.standard.set(maxNumberPages, forKey: maxPages)
        
    }
}


enum PageHalf: String {
    case top
    case bottom
}
