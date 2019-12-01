import UIKit



class ProfileDropdownTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    func configureCell(dataArray:[String], index:Int) {
        
        self.titleLabel.text = "\(dataArray[index])"
        
        if (index == 0) {
            self.titleLabel.textColor =  #colorLiteral(red: 0.7752474546, green: 0.3023262918, blue: 0.373683393, alpha: 1)
            self.titleLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
            
        }
        
        var iconName = "DropDown_\(dataArray[index])"
        iconName = iconName.replacingOccurrences(of: " ", with: "_")
        self.iconView.image = UIImage(named: iconName)
        //        let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
        //        if paymentTypePurchased >= 0
        //        {
        //            if (index == 1) {
        //
        //            }
        //        }
        
        if (index == 1) {
            //            let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
            //            print("paymentTypePurchased ====> \(paymentTypePurchased)")
            //            if (paymentTypePurchased == 0) {
            //                self.titleLabel.text = "Add Watermark"
            //            }
            //
            //            if (paymentTypePurchased == 1 || paymentTypePurchased == 2) {
            //                self.titleLabel.text = "Add Watermark"
            //                self.iconView.image = UIImage(named: "DropDown_Add_Watermark_unlocked")
            //            }
            
        }
        
        if (index == 2) {
            //            let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
            //            print("paymentTypePurchased ====> \(paymentTypePurchased)")
            
            //            if (paymentTypePurchased == 1 || paymentTypePurchased == 2) {
            //                self.iconView.image = UIImage(named: "DropDown_RestoreGrowthOrPro")
            //            }
        }
        //        if (index == 7) {
        //            let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
        //            print("paymentTypePurchased ====> \(paymentTypePurchased)")
        //
        //            if (paymentTypePurchased == 1 || paymentTypePurchased == 2 || paymentTypePurchased == 0) {
        //                self.iconView.image = UIImage(named: "DropDown_High_Resolution_unlocked")
        //            }
        //            else {
        //                self.iconView.image = UIImage(named:"DropDown_High_Resolution_Locked")
        //            }
        //        }
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
    }
    
}
