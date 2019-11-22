////
////  MergeProductBrandCompanyPopUpViewController.swift
////  Promptchu
////
////  Created by Arya S on 08/09/19.
////  Copyright © 2019 AryaSreenivasan. All rights reserved.
////
//
//import UIKit
//
//@objc protocol MergeProductBrandCompanyPopUpViewControllerDelegate{
//    @objc optional func mergeProductBrandCompanyPopUpVCUploadButtonClicked(dataDictToBePostedModified:[String:Any])
//}
//
//class MergeProductBrandCompanyPopUpViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
//    
//    var delegate:MergeProductBrandCompanyPopUpViewControllerDelegate?
//    
//    @IBOutlet weak var productField: UITextField!
//    @IBOutlet weak var brandField: UITextField!
//    @IBOutlet weak var companyField: UITextField!
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var bgImageView: UIImageView!
//    
//    var dataDictToBePosted:[String:Any] = [:]
//    
//    var tempSelectedCompanyId:String = ""
//    var tempSelectedCompanyName:String = ""
//    var dataArray:[CompanyDataArray] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        //        bgImageView.backgroundColor = UIColor.clear
//        tableView.alpha = 0
//        tableView.layer.borderColor = UIColor.lightGray.cgColor
//        tableView.layer.borderWidth = 1.0
//        productField.becomeFirstResponder()
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (dataArray.count > 0) {
//            return dataArray.count
//        }
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell =  UITableViewCell(style: .default, reuseIdentifier: "cell")
//        if (dataArray.count > indexPath.row) {
//            cell.textLabel?.text = dataArray[indexPath.row].name
//        }else {
//            let companyName = companyField.text ?? ""
//            cell.textLabel?.text = "Add \(companyName)"
//        }
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if (dataArray.count > indexPath.row) {
//            companyField.text = dataArray[indexPath.row].name
//            tempSelectedCompanyName = dataArray[indexPath.row].name
//            tempSelectedCompanyId   = dataArray[indexPath.row]._id
//            
//        }else {
//            let companyName = companyField.text ?? ""
//            print("Add \(companyName)...")
//            addNewCompanyBykeyword()
//        }
//        tableView.alpha = 0
//    }
//    
//    @IBAction func productFieldTextChanged(_ sender: UITextField) {
//        searchCompanyBykeyword()
//    }
//    
//    func searchCompanyBykeyword() {
//        let companyFieldString = companyField.text ?? ""
//        print("companyFieldString====>\(companyFieldString)")
//        //if (companyFieldString.count == 0) {return}
//        ApiManager().getCompanyFromSearchKeyword(keyword: companyFieldString) { (responseDict, error) in
//            if (error == nil) {
//                self.dataArray = responseDict.data
//            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.tableView.alpha = 1
//            }
//        }
//    }
//    
//    func addNewCompanyBykeyword() {
//        let companyFieldString = companyField.text ?? ""
//        print("companyFieldString====>\(companyFieldString)")
//        //if (companyFieldString.count == 0) {return}
//        ApiManager().addNewCompanyWith(name: companyFieldString) { (responseDict, error) in
//            if (error == nil) {
//                if(responseDict.data.count > 0) {
//                    let newlyAddedCompanyName = responseDict.data[0].name
//                    let newlyAddedCompanyId   = responseDict.data[0]._id
//                    self.tempSelectedCompanyName = newlyAddedCompanyName
//                    self.tempSelectedCompanyId   = newlyAddedCompanyId
//                    self.companyField.text = newlyAddedCompanyName
//                }
//            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                self.tableView.alpha = 0
//            }
//        }
//    }
//    
//    @IBAction func uploadButtonClicked(_ sender: Any) {
//        let product = productField.text ?? ""
//        let brand   = brandField.text ?? ""
//        
//        dataDictToBePosted["product"] = product
//        dataDictToBePosted["brand"] = brand
//        
//        var companyDict:[String:Any] = [:]
//        companyDict["_id"] = tempSelectedCompanyId
//        companyDict["name"] = tempSelectedCompanyName
//        dataDictToBePosted["company"] = companyDict
//        
//        self.dismiss(animated: true) {
//            self.delegate?.mergeProductBrandCompanyPopUpVCUploadButtonClicked!(dataDictToBePostedModified: self.dataDictToBePosted)
//        }
//        
//    }
//    
//    @IBAction func cancelButtonClicked(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        tableView.alpha = 0
//        return true
//    }
//    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if (textField.tag == 0 || textField.tag == 1) {
//            tableView.alpha = 0
//        }
//        return true
//    }
//    
//}
