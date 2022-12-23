//
//  ListDialogVC.swift
//  OS-Final
//
//  Created by 王奕翔 on 2022/12/21.
//

import UIKit

@objc protocol ListDialogVCDelegate: AnyObject {
    func listDidClick(index: Int)
}

class ListDialogVC: UIViewController {
    
    @IBOutlet var view_background: UIView!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableView_height: NSLayoutConstraint!
    
    private var albumData = [albumDataInfo]()
    
    weak var delegate: ListDialogVCDelegate?
    
    convenience init(albumData: [albumDataInfo]) {
        self.init()
        self.albumData = albumData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentsInit()
    }
    
    private func componentsInit() {
        view_background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTapped)))
        tableViewInit()
    }
    
    private func tableViewInit() {
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = .blue_C1E3FC
        tableView.register(UINib(nibName: "ListDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    @objc private func cancelTapped() {
        dialogDismiss()
    }
}

extension ListDialogVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ListDetailTableViewCell else { return ListDetailTableViewCell() }
        let selectedView = UIView()
        selectedView.backgroundColor = .blue_C1E3FC
        cell.selectedBackgroundView = selectedView
        if !albumData.isEmpty, indexPath.row < albumData.count {
            cell.setCell(data: albumData[indexPath.row])
        } else {
            cell.setCell(title: "新增相簿")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.listDidClick(index: indexPath.row)
    }
}
