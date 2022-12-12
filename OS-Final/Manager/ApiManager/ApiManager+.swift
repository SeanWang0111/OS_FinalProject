//
//  ApiManager+.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/10.
//

import Foundation

extension APIManager {
    
    // @命名規則: do + apiName
    
    static func doMediaGetter(url: String) {
        self.httpGet(apiName: "mediaGetter?url=\(url)", resClass: MediaGetterRes.self)
    }
}
