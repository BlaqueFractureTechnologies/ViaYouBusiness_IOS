//
//  MergeVideoInfoViewController.swift
//  Promptchu
//
//  Created by Arya S on 31/10/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit

class MergeVideoInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var videoName: String = ""
    var dateCreated: String = ""
    var sizeOfVideo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if indexPath.row == 0 {
            cell.textLabel?.text = "Name: \(self.videoName)"
        }
        else if indexPath.row == 1 {
            cell.textLabel?.text = "Date Created:  \(self.dateCreated)"
        }
        else {
            cell.textLabel?.text = "Video Size:  \(self.sizeOfVideo)"
        }
        
        return cell
    }
    
    @IBAction func dismissButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
