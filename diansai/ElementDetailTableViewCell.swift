//
//  ElementDetailTableViewCell.swift
//  diansai
//
//  Created by JiaCheng on 2019/8/2.
//  Copyright © 2019 JiaCheng. All rights reserved.
//

import UIKit
import AudioToolbox

class ElementDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var myImageView: UIImageView!
    var number = -1

    @IBAction func detailAct(_ sender: UIButton) {
        ElementsSettingTableViewController.destinationName = "Edit"
        ElementsSettingTableViewController.editNumber = self.number
        
        AudioServicesPlaySystemSound(1519)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
