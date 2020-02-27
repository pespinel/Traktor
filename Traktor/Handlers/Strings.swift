//
//  Extensions.swift
//  Traktor
//
//  Created by Pablo on 10/11/2019.
//  Copyright © 2019 Pablo. All rights reserved.
//

import Foundation

extension String {

    func strstr(needle: String, beforeNeedle: Bool = false) -> String? {
        guard let range = self.range(of: needle) else { return nil }

        if beforeNeedle {
            return String(self[..<range.lowerBound])
        }
        return String(self[range.upperBound...])
    }

}
