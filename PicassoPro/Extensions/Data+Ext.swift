//
//  Data+Ext.swift
//  PicassoPro
//
//  Created by Ashiqur Rahman on 12/2/26.
//


import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
