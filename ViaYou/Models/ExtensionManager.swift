//
//  ExtensionManager.swift
//
//  Created by Arya S on 22/07/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit
import CoreLocation
import Contacts

extension UIView {
    func applySignUpButtonTheme() {
        self.backgroundColor = UIColor.white
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = self.frame.size.height/2.0
        self.clipsToBounds = true
    }
    
    func applySignInTextFieldBgTheme() {
        self.backgroundColor = UIColor.white
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1.5
        self.clipsToBounds = true
    }
    
    func createHoleInBottomBar() {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
        maskLayer.fillColor = UIColor.black.cgColor
        
        let radius: CGFloat = 25.0
        let rect = CGRect(x:  (UIScreen.main.bounds.size.width/2.0) - radius,
                          y:  -radius,
                          width: 2 * radius,
                          height: 2 * radius)
        
        // Create the path.
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        // Append the circle to the path so that it is subtracted.
        path.append(UIBezierPath(ovalIn: rect))
        maskLayer.path = path.cgPath
        
        // Set the mask of the view.
        self.layer.mask = maskLayer
    }
    
    func imageViewCircle() {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 0.5
    }
    
    func addShadowToTitleBarShadowView() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: -1, height: 2)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func addShadowToBottomBarPlusButtonContainer() {
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 4.0
    }
    
    func applyNewsFeedMainProfileButtonStyle() {
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.yellow.cgColor
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
    }
    
    func addShadowToEditProfileTableShadowViews() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: -1, height: 2)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.4
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func themeYellowColor()-> UIColor {
        return UIColor(red: 255.0/255.0, green: 201.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    }
    
    func themeRedColor()-> UIColor {
        return UIColor(red: 214.0/255.0, green: 85.0/255.0, blue: 107.0/255.0, alpha: 1.0)
    }
    
    
    func addDropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 10
    }
}

extension UIButton {
    func applySignUp3ButtonTheme() {
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.yellow.cgColor
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    func addShadowToBottomPlusButton() {
        self.layer.cornerRadius = self.frame.size.width/2.0
        self.layer.masksToBounds = true
    }
}

extension UIViewController {
    func displaySingleButtonAlert(message:String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UICollectionView {
    func setCustomFlowLayout() {
        if let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = (UIScreen.main.bounds.size.width/2.0)-10
            flowLayout.estimatedItemSize = CGSize(width: width, height: 300)
        }
    }
}

extension UICollectionViewCell {
    func addAppCollectionViewShadowAndBorder() {
        self.contentView.layer.borderWidth = 0.75
        self.contentView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
    }
}

extension UITextField {
    func makeWhitePlaceholder() {
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.groupTableViewBackground])
    }
}

extension UITextView {
    func addDoneButtonToKeyboard(myAction:Selector?){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: myAction)
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
}

extension String {
    func makeStartingBioInYellow()->NSAttributedString {
        var dataString:String = self
        if (dataString.count<3) {
            dataString = "Bio: "
        }
        let range = NSMakeRange(0, 3)
        let attributedString = NSMutableAttributedString(string:dataString)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 255.0/255.0, green: 201.0/255.0, blue: 0.0/255.0, alpha: 1.0) , range: range)
        return attributedString
    }
    
    func getReadableDateString()->String {
        var readableDateString = self
        readableDateString = readableDateString.components(separatedBy: "T").first ?? readableDateString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = dateFormatter.date(from: readableDateString)
        dateFormatter.dateFormat = "MMM dd, yyyy"
        if (date != nil) {
            readableDateString = dateFormatter.string(from: date!)
        }
        return readableDateString
    }
    
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
    
    
    //MARK:-
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
}

extension UIViewController  {
    func displayAlert(msg:String) {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func getContacts(completionHandler: @escaping (_ completedStatus:Bool,_ contactsArray: [PhoneContact]) -> Void){
        var contacts: [CNContact] = []
        
        var localCountryCode = Locale.current.regionCode ?? ""
        localCountryCode = self.getCountryPhonceCode(localCountryCode)
        localCountryCode = "+\(localCountryCode)"
        
        // localCountryCode = "+61"
        print("getContacts :: Locale.current.regionCode = \(localCountryCode)")
        
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers :: error = \(error.localizedDescription)")
        }
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                contacts.append(contentsOf: containerResults)
            } catch {
                print("Error fetching containers :: error = \(error.localizedDescription)")
            }
        }
        print("Fetched contacts \(contacts.count)")
        
        var phoneContacts: [PhoneContact] = []
        for i in 0..<contacts.count {
            let firstName  = contacts[i].givenName
            let familyName = contacts[i].familyName
            var phoneNumberFromContacts = contacts[i].phoneNumbers
            
            let phoneContact = PhoneContact()
            phoneContact.firstName = firstName
            phoneContact.familyName = familyName
            phoneContact.fullName = "\(phoneContact.firstName) \(phoneContact.familyName)"
            
            var phoneNumbersArray:[String] = []
            for j in 0..<phoneNumberFromContacts.count {
                if let phone = (phoneNumberFromContacts[j].value ).value(forKey: "stringValue") as? String {
                    var phoneFromContact = phone
                    phoneFromContact = phoneFromContact.replacingOccurrences(of: "(", with: "");
                    phoneFromContact = phoneFromContact.replacingOccurrences(of: ")", with: "");
                    phoneFromContact = phoneFromContact.replacingOccurrences(of: "-", with: "");
                    phoneFromContact = phoneFromContact.replacingOccurrences(of: " ", with: ""); // Some
                    phoneFromContact = phoneFromContact.replacingOccurrences(of: " ", with: ""); // Both are different :|
                    phoneFromContact = phoneFromContact.trimmingCharacters(in: NSCharacterSet.whitespaces)
                    
                    if (phoneFromContact.hasPrefix("00") == false &&
                        phoneFromContact.hasPrefix("+") == false) {
                        phoneFromContact = "\(Int(phoneFromContact) ?? 0)"
                        phoneFromContact = "\(localCountryCode)\(phoneFromContact)"
                        // If no country code is prepened on the number
                    }
                    phoneNumbersArray.append(phoneFromContact)
                    
                    if contacts[i].thumbnailImageData != nil {
                        if UIImage(data:contacts[i].thumbnailImageData!,scale:1.0) != nil {
                            if let pic = UIImage(data:contacts[i].thumbnailImageData!,scale:1.0) {
                                phoneContact.isProfilePicAvailable = true
                                phoneContact.profilePic = pic
                            }
                        }
                    }
                }
            }
            phoneContact.phoneNumbers = phoneNumbersArray
            
            if (phoneContact.phoneNumbers.count > 0) {
                phoneContacts.append(phoneContact)
            }
            
        }
        print("Fetched phoneContacts contacts \(phoneContacts.count)")
        
        completionHandler(true,phoneContacts)
        
    }
    
    func getCountryPhonceCode (_ country : String) -> String {
        var countryDictionary  = ["AF":"93",
                                  "AL":"355",
                                  "DZ":"213",
                                  "AS":"1",
                                  "AD":"376",
                                  "AO":"244",
                                  "AI":"1",
                                  "AG":"1",
                                  "AR":"54",
                                  "AM":"374",
                                  "AW":"297",
                                  "AU":"61",
                                  "AT":"43",
                                  "AZ":"994",
                                  "BS":"1",
                                  "BH":"973",
                                  "BD":"880",
                                  "BB":"1",
                                  "BY":"375",
                                  "BE":"32",
                                  "BZ":"501",
                                  "BJ":"229",
                                  "BM":"1",
                                  "BT":"975",
                                  "BA":"387",
                                  "BW":"267",
                                  "BR":"55",
                                  "IO":"246",
                                  "BG":"359",
                                  "BF":"226",
                                  "BI":"257",
                                  "KH":"855",
                                  "CM":"237",
                                  "CA":"1",
                                  "CV":"238",
                                  "KY":"345",
                                  "CF":"236",
                                  "TD":"235",
                                  "CL":"56",
                                  "CN":"86",
                                  "CX":"61",
                                  "CO":"57",
                                  "KM":"269",
                                  "CG":"242",
                                  "CK":"682",
                                  "CR":"506",
                                  "HR":"385",
                                  "CU":"53",
                                  "CY":"537",
                                  "CZ":"420",
                                  "DK":"45",
                                  "DJ":"253",
                                  "DM":"1",
                                  "DO":"1",
                                  "EC":"593",
                                  "EG":"20",
                                  "SV":"503",
                                  "GQ":"240",
                                  "ER":"291",
                                  "EE":"372",
                                  "ET":"251",
                                  "FO":"298",
                                  "FJ":"679",
                                  "FI":"358",
                                  "FR":"33",
                                  "GF":"594",
                                  "PF":"689",
                                  "GA":"241",
                                  "GM":"220",
                                  "GE":"995",
                                  "DE":"49",
                                  "GH":"233",
                                  "GI":"350",
                                  "GR":"30",
                                  "GL":"299",
                                  "GD":"1",
                                  "GP":"590",
                                  "GU":"1",
                                  "GT":"502",
                                  "GN":"224",
                                  "GW":"245",
                                  "GY":"595",
                                  "HT":"509",
                                  "HN":"504",
                                  "HU":"36",
                                  "IS":"354",
                                  "IN":"91",
                                  "ID":"62",
                                  "IQ":"964",
                                  "IE":"353",
                                  "IL":"972",
                                  "IT":"39",
                                  "JM":"1",
                                  "JP":"81",
                                  "JO":"962",
                                  "KZ":"77",
                                  "KE":"254",
                                  "KI":"686",
                                  "KW":"965",
                                  "KG":"996",
                                  "LV":"371",
                                  "LB":"961",
                                  "LS":"266",
                                  "LR":"231",
                                  "LI":"423",
                                  "LT":"370",
                                  "LU":"352",
                                  "MG":"261",
                                  "MW":"265",
                                  "MY":"60",
                                  "MV":"960",
                                  "ML":"223",
                                  "MT":"356",
                                  "MH":"692",
                                  "MQ":"596",
                                  "MR":"222",
                                  "MU":"230",
                                  "YT":"262",
                                  "MX":"52",
                                  "MC":"377",
                                  "MN":"976",
                                  "ME":"382",
                                  "MS":"1",
                                  "MA":"212",
                                  "MM":"95",
                                  "NA":"264",
                                  "NR":"674",
                                  "NP":"977",
                                  "NL":"31",
                                  "AN":"599",
                                  "NC":"687",
                                  "NZ":"64",
                                  "NI":"505",
                                  "NE":"227",
                                  "NG":"234",
                                  "NU":"683",
                                  "NF":"672",
                                  "MP":"1",
                                  "NO":"47",
                                  "OM":"968",
                                  "PK":"92",
                                  "PW":"680",
                                  "PA":"507",
                                  "PG":"675",
                                  "PY":"595",
                                  "PE":"51",
                                  "PH":"63",
                                  "PL":"48",
                                  "PT":"351",
                                  "PR":"1",
                                  "QA":"974",
                                  "RO":"40",
                                  "RW":"250",
                                  "WS":"685",
                                  "SM":"378",
                                  "SA":"966",
                                  "SN":"221",
                                  "RS":"381",
                                  "SC":"248",
                                  "SL":"232",
                                  "SG":"65",
                                  "SK":"421",
                                  "SI":"386",
                                  "SB":"677",
                                  "ZA":"27",
                                  "GS":"500",
                                  "ES":"34",
                                  "LK":"94",
                                  "SD":"249",
                                  "SR":"597",
                                  "SZ":"268",
                                  "SE":"46",
                                  "CH":"41",
                                  "TJ":"992",
                                  "TH":"66",
                                  "TG":"228",
                                  "TK":"690",
                                  "TO":"676",
                                  "TT":"1",
                                  "TN":"216",
                                  "TR":"90",
                                  "TM":"993",
                                  "TC":"1",
                                  "TV":"688",
                                  "UG":"256",
                                  "UA":"380",
                                  "AE":"971",
                                  "GB":"44",
                                  "US":"1",
                                  "UY":"598",
                                  "UZ":"998",
                                  "VU":"678",
                                  "WF":"681",
                                  "YE":"967",
                                  "ZM":"260",
                                  "ZW":"263",
                                  "BO":"591",
                                  "BN":"673",
                                  "CC":"61",
                                  "CD":"243",
                                  "CI":"225",
                                  "FK":"500",
                                  "GG":"44",
                                  "VA":"379",
                                  "HK":"852",
                                  "IR":"98",
                                  "IM":"44",
                                  "JE":"44",
                                  "KP":"850",
                                  "KR":"82",
                                  "LA":"856",
                                  "LY":"218",
                                  "MO":"853",
                                  "MK":"389",
                                  "FM":"691",
                                  "MD":"373",
                                  "MZ":"258",
                                  "PS":"970",
                                  "PN":"872",
                                  "RE":"262",
                                  "RU":"7",
                                  "BL":"590",
                                  "SH":"290",
                                  "KN":"1",
                                  "LC":"1",
                                  "MF":"590",
                                  "PM":"508",
                                  "VC":"1",
                                  "ST":"239",
                                  "SO":"252",
                                  "SJ":"47",
                                  "SY":"963",
                                  "TW":"886",
                                  "TZ":"255",
                                  "TL":"670",
                                  "VE":"58",
                                  "VN":"84",
                                  "VG":"284",
                                  "VI":"340"]
        if countryDictionary[country] != nil {
            return countryDictionary[country]!
        }
            
        else {
            return ""
        }
    }
}

extension UINavigationController {
    
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
            popToViewController(vc, animated: animated)
        }
    }
    
    func popViewControllers(viewsToPop: Int, animated: Bool = true) {
        if viewControllers.count > viewsToPop {
            let vc = viewControllers[viewControllers.count - viewsToPop - 1]
            popToViewController(vc, animated: animated)
        }
    }
}

