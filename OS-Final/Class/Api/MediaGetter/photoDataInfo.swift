//
//  photoDataInfo.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/12.
//

import Foundation

class photoDataInfo: Codable {
    
    var type: String
    var previewImageUrl: String
    var originalContentUrl: String
    
    var image: Data
    var video: Data
    
    init(type: String, previewImageUrl: String, originalContentUrl: String, image: Data, video: Data) {
        self.type = type
        self.previewImageUrl = previewImageUrl
        self.originalContentUrl = originalContentUrl
        self.image = image
        self.video = video
    }
}
