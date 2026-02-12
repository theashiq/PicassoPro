//
//  MultipartRequest.swift
//  PicassoPro
//
//  Created by Ashiqur Rahman on 12/2/26.
//


import Foundation

struct MultipartRequest {
    let boundary: String = "Boundary-\(UUID().uuidString)"
    
    func finalize(fields: [String: String]) -> Data {
        var body = Data()
        
        for (key, value) in fields {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
}
