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
    var createGroupUrl = "https://guardian-app-v1.herokuapp.com/api/v1/groupsapi"
    var dashboardUrl = "https://guardian-app-v1.herokuapp.com/api/v1/dashboardapi"
    var fileurl =  "https://guardian-app-v1.herokuapp.com/api/v1/fileurl.json"
    var actionRequrl =  "https://guardian-app-v1.herokuapp.com/api/v1/actionReq.json"
    
    
    var s3url = "https://guardian-v1-storage.s3-us-west-1.amazonaws.com/"
    
    
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
        createGroupUrl = "https://guardian-app-v1.herokuapp.com/api/v1/groupsapi"
        dashboardUrl = "https://guardian-app-v1.herokuapp.com/api/v1/dashboardapi"
        fileurl =  "https://guardian-app-v1.herokuapp.com/api/v1/fileurl.json"
        actionRequrl =  "https://guardian-app-v1.herokuapp.com/api/v1/actionReq.json"

    }
    func makeUrlsDevelopment(){
        
        actionCableUrl = "http://localhost:3000/cable"
        baseUrl = "http://localhost:3000/api/v1/groupsapi/"
        authUrl = "http://localhost:3000/api/v1/auth_user"
        createUrl = "http://localhost:3000/users.json"
        createGroupUrl = "http://localhost:3000/api/v1/groupsapi"
        dashboardUrl = "http://localhost:3000/api/v1/dashboardapi"
        fileurl =  "http://localhost:3000/api/v1/fileurl.json"
        actionRequrl =  "http://localhost:3000/api/v1/actionReq.json"
    }
    

}
