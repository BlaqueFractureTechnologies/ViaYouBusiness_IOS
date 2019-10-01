//
//  ExtensionManager.swift
//
//  Created by Arya S on 22/07/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit
import CoreLocation

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
}

//extension AppDelegate {
//    func getDistanceFrom(monitoringLocation: CLLocation) -> String {
//        var distanceString:String = "0.0"
//        let currentLocation = CLLocation(latitude: Double(DefaultWrapper().getUserLat()) ?? 0.0, longitude: Double(DefaultWrapper().getUserLong()) ?? 0.0)
//        print("getAllTagDetails :: currentLocation latitude====>\(currentLocation.coordinate.latitude)")
//        print("getAllTagDetails :: currentLocation longitude====>\(currentLocation.coordinate.longitude)")
//
//        let distance = currentLocation.distance(from: monitoringLocation)
//        print(String(format: "The distance is %0.2f m", distance))
//        distanceString = String(format: "%0.2f", distance)
//        return distanceString
//    }
//}
