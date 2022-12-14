//
//  Array+.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/13.
//

import Foundation

extension Array {
    func getObject(at index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
}
