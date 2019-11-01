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
        
        if (index == 2) {
            let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
            print("paymentTypePurchased ====> \(paymentTypePurchased)")
            
            if (paymentTypePurchased == 1 || paymentTypePurchased == 2 || paymentTypePurchased == 0) {
                self.iconView.image = UIImage(named: "DropDown_Add_Watermark_unlocked")
            }
        }
        
        if (index == 3) {
            let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
            print("paymentTypePurchased ====> \(paymentTypePurchased)")
            
            if (paymentTypePurchased == 1 || paymentTypePurchased == 2) {
                self.iconView.image = UIImage(named: "DropDown_RestoreGrowthOrPro")
            }
        }
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
    }
    
}
