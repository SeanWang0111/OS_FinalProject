//
//  BarCollectionViewCell.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/11/25.
//

import UIKit

class BarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageView_height: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCell(index: Int, isSelected: Bool) {
        var imageName: String = ""
        var selectedName: String = ""
        
        switch index {
        case 0:
            imageName = "photo"
            selectedName = "photo_selected"
            
        case 1:
            imageName = "folder"
            selectedName = "folder_selected"
            
        case 2:
            imageName = "gear"
            selectedName = "gear_selected"
            
        default:
            break
        }
        
        imageView.image = UIImage(named: isSelected ? selectedName : imageName)
        imageView_height.constant = isSelected ? 40 : 30
    }
}
