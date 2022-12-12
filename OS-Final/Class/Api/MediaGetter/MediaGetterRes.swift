//
//  MediaGetterRes.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/10.
//

import Foundation

class MediaGetterRes: BaseRes {
    
    var messages: [Messages]?
    
    private enum CodingKeys: String, CodingKey {
        case messages
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messages = try? container.decode([Messages].self, forKey: .messages)
        try super.init(from: decoder)
    }
    
    class Messages: Codable {
        var type: String
        var previewImageUrl: String
        var originalContentUrl: String
    }
}
