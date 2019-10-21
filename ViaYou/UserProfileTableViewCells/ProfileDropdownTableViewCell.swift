import UIKit



class ProfileDropdownTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    
    
    func configureCell(dataArray:[String], index:Int) {
        
        self.titleLabel.text = "\(dataArray[index])\n***"
        
        if (index == 0) {
            
            self.titleLabel.textColor =  #colorLiteral(red: 0.7752474546, green: 0.3023262918, blue: 0.373683393, alpha: 1)
            
        }
        
        
        
        var iconName = "DropDown_\(dataArray[index])"
        
        iconName = iconName.replacingOccurrences(of: " ", with: "_")
        
        self.iconView.image = UIImage(named: iconName)
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
    }
    
}
