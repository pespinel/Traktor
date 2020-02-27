//
//  URLs.swift
//  Traktor
//
//  Created by Pablo on 17/11/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import UIKit

extension URL {
    func queryDict() -> [String: Any] {
        var info: [String: Any] = [String: Any]()
        if let queryString = self.query{
            for parameter in queryString.components(separatedBy: "&"){
                let parts = parameter.components(separatedBy: "=")
                if parts.count > 1 {
                    let key = parts[0].removingPercentEncoding
                    let value = parts[1].removingPercentEncoding
                    if key != nil && value != nil{
                        info[key!] = value
                    }
                }
            }
        }
        return info
    }
}
