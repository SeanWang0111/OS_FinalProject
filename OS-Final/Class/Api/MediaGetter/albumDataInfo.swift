//
//  albumDataInfo.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/21.
//

import Foundation

class albumDataInfo: Codable {
    
    var image: Data
    var title: String
    var total: Int
    
    var photoData: [photoDataInfo]
    
    init(image: Data, title: String, total: Int, photoData: [photoDataInfo]) {
        self.image = image
        self.title = title
        self.total = total
        self.photoData = photoData
    }
}
