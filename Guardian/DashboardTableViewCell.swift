//
//  DashboardTableViewCell.swift
//  Guardian
//
//  Created by Henry Boswell on 5/12/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import Foundation
import UIKit

class DashboardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var InstructorLabel: UILabel!
    @IBOutlet weak var CheckView: UIView!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
}

class DashboardGuardianTableViewCell: UITableViewCell {
    
    @IBOutlet weak var NameLabel: UILabel!
    
    @IBOutlet weak var CheckView: UIView!
    
}
