//
//  UserDefaultManager.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/12.
//

import UIKit
import Foundation
class UserDefaultManager {
    
    private enum defaultKeyStr: String {
        case album = "Album"
        case photo = "Photo"
    }
    
    /// 相簿
    // 自己本地清除用途
    static func clearAlbum() {
        UserDefaults.standard.removeObject(forKey: defaultKeyStr.album.rawValue)
    }
    
    static func getAlbum() -> [albumDataInfo] {
        guard let data = UserDefaults().object(forKey: defaultKeyStr.album.rawValue) as? Data, let dataInfo = try? JSONDecoder().decode([albumDataInfo].self, from: data) else { return [albumDataInfo]() }
        return dataInfo
    }
    
    static func setAlbum(_ album: [albumDataInfo]) {
        let data = try? album.toData()
        UserDefaults().set(data, forKey: defaultKeyStr.album.rawValue)
        UserDefaults().synchronize()
    }
    
    /// 圖庫
    // 自己本地清除用途
    static func clearPhoto() {
        UserDefaults.standard.removeObject(forKey: defaultKeyStr.photo.rawValue)
    }
    
    static func getPhoto() -> [photoDataInfo] {
        guard let data = UserDefaults().object(forKey: defaultKeyStr.photo.rawValue) as? Data, let dataInfo = try? JSONDecoder().decode([photoDataInfo].self, from: data) else { return [photoDataInfo]() }
        return dataInfo
    }
    
    static func setPhoto(_ photo: [photoDataInfo]) {
        let data = try? photo.toData()
        UserDefaults().set(data, forKey: defaultKeyStr.photo.rawValue)
        UserDefaults().synchronize()
    }
}
