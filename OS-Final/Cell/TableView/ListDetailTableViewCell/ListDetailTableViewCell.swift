//
//  ListDetailTableViewCell.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/21.
//

import UIKit

class ListDetailTableViewCell: UITableViewCell {
    
    @IBOutlet var imageView_cover: UIImageView!
    @IBOutlet var label_title: UILabel!
    @IBOutlet var label_count: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(data: albumDataInfo) {
        imageView_cover.image = UIImage(data: data.image)
        label_title.text = data.title
        label_count.text = "\(data.total)"
    }
    
    func setCell(title: String) {
        label_title.text = title
        label_count.text = ""
    }
}
