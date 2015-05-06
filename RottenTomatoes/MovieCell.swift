//
//  MovieCell.swift
//  RottenTomatoes
//
//  Created by Ningchong Chen on 5/5/15.
//  Copyright (c) 2015 Ningchong Chen. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var index: Int?
}
