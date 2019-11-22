//
//  MergeTagPopUpViewController.swift
//  Promptchu
//
//  Created by Arya S on 20/09/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit
import Firebase



//// has UserShadowsListResponse
//
//@objc protocol MergeTagPopUpViewControllerDelegate{
//    @objc optional func mergeTagPopUpViewControllerDoneButtonClicked(passedShadowsDataArray:[UserShadowsArrayObject])
//}
//
//class MergeTagPopUpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//
//    var delegate:MergeTagPopUpViewControllerDelegate?
//
//    @IBOutlet weak var tableView: UITableView!
//
//  //  var shadowsDataArray:[UserShadowsArrayObject] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return shadowsDataArray.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MergeTagPopUpTableViewCell", for: indexPath) as! MergeTagPopUpTableViewCell
//       // cell.configureCell(dataDict: shadowsDataArray[indexPath.row])
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if (shadowsDataArray[indexPath.row].isSelectedForTag == true) {
//            shadowsDataArray[indexPath.row].isSelectedForTag = false
//        }else {
//            shadowsDataArray[indexPath.row].isSelectedForTag = true
//        }
//        self.tableView.reloadData()
//    }
//
//    @IBAction func doneButtonClicked(_ sender: UIButton) {
//        self.dismiss(animated: true) {
//            self.delegate?.mergeTagPopUpViewControllerDoneButtonClicked!(passedShadowsDataArray: self.shadowsDataArray)
//        }
//    }
//
//    @IBAction func backButtonClicked(_ sender: UIButton) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//}
