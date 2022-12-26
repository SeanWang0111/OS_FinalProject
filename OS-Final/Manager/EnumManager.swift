//
//  EnumManager.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/19.
//

import Foundation

@objc public enum Titles: Int {
    
    case downLoadToApp
    case downLoadToAlbum
    case removeAlbum
    case removePhoto
    case removeSearch
    
    func TitleString(title: Titles, msg: String = "") -> String {
        switch title {
        case .downLoadToApp:
            return "確認要下載至App裝置中？"
            
        case .downLoadToAlbum:
            return "確認要下載至手機相簿中？"
            
        case .removeAlbum:
            return "確認要刪除相簿？"
            
        case .removePhoto:
            return "確認要刪除？"
            
        case .removeSearch:
            return "確認要移除這次搜尋紀錄？"
        }
    }
}
