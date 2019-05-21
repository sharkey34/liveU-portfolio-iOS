//
//  AppliedArtistTableViewCell.swift
//  LiveU
//
//  Created by Eric Sharkey on 9/14/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//

import UIKit

class AppliedArtistTableViewCell: UITableViewCell {
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
