//
//  LibraryFeedsCollectionViewCell.swift
//  ViaYou
//
//  Created by Arya S on 29/09/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class LibraryFeedsCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var infoTableView: UITableView!
    @IBOutlet weak var infoSliderCloseButton: UIButton!
    
    @IBOutlet weak var infoPopUpHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        infoTableView.delegate = self
        infoTableView.dataSource = self
    }
    
    func configureCell(data:String) {
        if (data == "0") {
            self.infoPopUpHeight.constant = 0
        }else {
            UIView.animate(withDuration: 0.4) {
                self.infoPopUpHeight.constant = 170
                self.layoutIfNeeded()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "Info \(indexPath.row)"
        return cell
    }
}
