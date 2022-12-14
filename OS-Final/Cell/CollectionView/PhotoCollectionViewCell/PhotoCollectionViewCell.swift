//
//  PhotoCollectionViewCell.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/6.
//

import UIKit
import SDWebImage

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var constant_height: NSLayoutConstraint!
    
    @IBOutlet var view_image: UIView!
    @IBOutlet var imageView_photo: UIImageView!
    
    @IBOutlet var imageView_video: UIImageView!
    
    @IBOutlet var view_check: UIView!
    
    @IBOutlet var view_plus: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        componentsInit()
    }
    
    func setCell(urlStr: String, isPlus: Bool) {
        view_image.isHidden = isPlus
        view_plus.isHidden = !isPlus
        view_check.isHidden = true
        imageView_photo.sd_setImage(with: URL(string: urlStr))
    }
    
    func setCell(data: photoDataInfo, isPlus: Bool) {
        view_image.isHidden = isPlus
        view_plus.isHidden = !isPlus
        view_check.isHidden = true
        imageView_video.isHidden = data.type == "image"
        
        if let image = UIImage(data: data.image) {
            imageView_photo.image = image
        } else {
            imageView_photo.sd_setImage(with: URL(string: data.previewImageUrl))
        }
    }
    
    func tagPhoto(isTag: Bool = false) {
        view_check.isHidden = !isTag
    }
    
    private func componentsInit() {
        constant_height.constant = (AppWidth - 30) / 3 - 10
    }
}
