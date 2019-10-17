//
//  StripePaymentViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 17/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import Stripe

class StripePaymentViewController: UIViewController, STPPaymentCardTextFieldDelegate {
    @IBOutlet weak var buyButton: UIButton!
    
    var passedTypeOfPayment: String = ""
    var cardField = STPPaymentCardTextField()
    var theme = STPTheme.default()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        title = "Card Field"
        view.backgroundColor = UIColor.white
        view.addSubview(cardField)
        edgesForExtendedLayout = []
        view.backgroundColor = theme.primaryBackgroundColor
        cardField.backgroundColor = theme.secondaryBackgroundColor
        cardField.textColor = theme.primaryForegroundColor
        cardField.placeholderColor = theme.secondaryForegroundColor
        cardField.borderColor = theme.accentColor
        cardField.borderWidth = 1.0
        cardField.textErrorColor = theme.errorColor
        cardField.postalCodeEntryEnabled = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationController?.navigationBar.stp_theme = theme
    }
    
    @objc func done() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 15
        cardField.frame = CGRect(x: padding,
                                 y: padding,
                                 width: view.bounds.width - (padding * 2),
                                 height: 50)
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func buyButtonClicked(_ sender: Any) {
        let cardParams = STPCardParams()
        cardParams.number = cardField.cardNumber
        cardParams.expMonth = cardField.expirationMonth
        cardParams.expYear = cardField.expirationYear
        cardParams.cvc = cardField.cvc
        
        
        STPAPIClient.shared().createToken(withCard: cardParams) { token, error in
            guard let token = token else {
                // Handle the error
                return
            }
            print("token == \(token)")
            let stringToken = String(describing: token)
            // Use the token in the next step
            ApiManager().confirmPaymentAPI(stripeToken: stringToken, type: self.passedTypeOfPayment, completion: { (response, error) in
                
                print(self.passedTypeOfPayment)
                print(stringToken)
                if error == nil {
                    print(response.success)
                    print(response.message)
                    self.displayAlert(msg: "Success! Payment Confirmed!")
                }
                else {
                    self.displayAlert(msg: "Sorry! Payment Failed! Please try again later!")
                    print(error.debugDescription)
                }
                
            })
        }
    }
    
    
}
