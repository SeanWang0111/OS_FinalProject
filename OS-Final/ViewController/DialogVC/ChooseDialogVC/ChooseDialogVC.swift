//
//  ChooseDialogVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/19.
//

import UIKit

protocol ChooseDialogVCDelegate: AnyObject {
    func confirmClickWith(title: Titles)
}

class ChooseDialogVC: UIViewController {
    
    @IBOutlet var view_background: UIView!
    
    @IBOutlet var label_title: UILabel!
    
    @IBOutlet var view_cancel: UIView!
    @IBOutlet var view_confirm: UIView!
    
    private var chooseTitle: Titles = .removePhoto
    
    weak var delegate: ChooseDialogVCDelegate?
    
    convenience init(title: Titles) {
        self.init()
        self.chooseTitle = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    private func componentsInit() {
        label_title.text = chooseTitle.TitleString(title: chooseTitle)
        viewInit()
    }
    
    private func viewInit() {
        view_background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTapped)))
        view_cancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTapped)))
        view_confirm.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(confirmTapped)))
    }
    
    @objc private func cancelTapped() {
        dialogDismiss()
    }
    
    @objc private func confirmTapped() {
        delegate?.confirmClickWith(title: chooseTitle)
    }
}
