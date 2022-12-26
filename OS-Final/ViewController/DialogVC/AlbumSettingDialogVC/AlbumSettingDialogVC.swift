//
//  AlbumSettingDialogVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/26.
//

import UIKit

@objc protocol AlbumSettingDialogVCDelegate: AnyObject {
    func indexDidClick(index: Int)
}

class AlbumSettingDialogVC: UIViewController {
    
    @IBOutlet var view_background: UIView!
    @IBOutlet var view_editCover: UIView!
    @IBOutlet var view_select: UIView!
    @IBOutlet var view_remove: UIView!
    
    weak var delegate: AlbumSettingDialogVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func componentsInit() {
        viewInit()
    }
    
    private func viewInit() {
        view_editCover.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view_remove.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        view_background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTapped)))
        view_editCover.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editTapped)))
        view_select.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectTapped)))
        view_remove.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeTapped)))
    }
    
    @objc private func cancelTapped() {
        dialogDismiss()
    }
    
    @objc private func editTapped() {
        delegate?.indexDidClick(index: 0)
    }
    
    @objc private func selectTapped() {
        delegate?.indexDidClick(index: 1)
    }
    
    @objc private func removeTapped() {
        delegate?.indexDidClick(index: 2)
    }
}
