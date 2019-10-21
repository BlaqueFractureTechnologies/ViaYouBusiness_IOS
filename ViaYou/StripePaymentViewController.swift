//
//  StripePaymentViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 17/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import Stripe

@objc protocol StripePaymentViewControllerDelegate{
    @objc optional func transactionSuccessful(passedTypeOfPayment: String)
    @objc optional func transactionFailed()
}

class StripePaymentViewController: UIViewController, STPPaymentCardTextFieldDelegate {
    
    var delegate:StripePaymentViewControllerDelegate?
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var selectedPlanLabel: UILabel!
    @IBOutlet weak var labelsContainer: UIView!
    
    var passedTypeOfPayment: String = ""
    var cardField = STPPaymentCardTextField()
    var theme = STPTheme.default()
    var selectedPlanName: String = ""
    var selectedPlanCharge: String = ""
    
    let tokenGot: String = ""
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
        amountLabel.text = selectedPlanCharge
        selectedPlanLabel.text = selectedPlanName
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationController?.navigationBar.stp_theme = theme
        
        labelsContainer.layer.borderColor = self.view.themeRedColor().cgColor
        labelsContainer.layer.borderWidth = 2.5
        labelsContainer.layer.cornerRadius = 5
        labelsContainer.clipsToBounds = true
        labelsContainer.layoutIfNeeded()
        
    }
    
    @objc func done() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        buyButton.addAppGradient()
        //        cancelButton.addAppGradient()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 15
        //        cardField.frame = CGRect(x: padding,
        //                                 y: padding,
        //                                 width: view.bounds.width - (padding * 2),
        //                                 height: 50)
        
        cardField.frame = CGRect(x: padding,
                                 y: 140,
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
            guard let token = token else {                // Handle the error
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
                    
                    let alert = UIAlertController(title: "Success!", message: "Payment Confirmed!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        self.navigationController?.dismiss(animated: true, completion: {
                            self.delegate?.transactionSuccessful!(passedTypeOfPayment: self.passedTypeOfPayment)
                        })
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                    //self.dismiss(animated: true, completion: nil)
                    
                }
                else {
                    self.displayAlert(msg: "Sorry! Payment Failed! Please try again later!")
                    print(error.debugDescription)
                }
            })
        }
    }
    
    
}
