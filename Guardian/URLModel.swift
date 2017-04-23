//
//  URLModel.swift
//  Guardian
//
//  Created by Henry Boswell on 4/17/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Foundation
import ActionCableClient
import SwiftyJSON


class URLModel  {
    static let sharedInstance = URLModel()
    
    
    var actionCableUrl = "wss://guardian-app-v1.herokuapp.com/cable"
    var baseUrl = "https://guardian-app-v1.herokuapp.com/api/v1/groupsapi/"
    var authUrl = "https://guardian-app-v1.herokuapp.com/api/v1/auth_user"
    var createUrl = "https://guardian-app-v1.herokuapp.com/users.json"
   
    /*
    var groupDataGetUrl = "https://guardian-app-v1.herokuapp.com/api/v1/groupsapi/"
    var individualDataGetUrl = "https://guardian-app-v1.herokuapp.com/api/v1/groupsapi/"
    var individualDataChangeUrl = "https://guardian-app-v1.herokuapp.com/api/v1/groupsapi/"
 */
    
    func makeUrlsProduction(){
        actionCableUrl = "wss://guardian-app-v1.herokuapp.com/cable"
        baseUrl = "https://guardian-app-v1.herokuapp.com/api/v1/groupsapi/"
        authUrl = "https://guardian-app-v1.herokuapp.com/api/v1/auth_user"
        createUrl = "https://guardian-app-v1.herokuapp.com/users.json"

    }
    func makeUrlsDevelopment(){
        
        actionCableUrl = "http://localhost:3000/cable"
        baseUrl = "http://localhost:3000/api/v1/groupsapi/"
        authUrl = "http://localhost:3000/api/v1/auth_user"
        createUrl = "http://localhost:3000/users.json"
    }
    

}
