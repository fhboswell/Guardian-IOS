//
//  ActionCableController.swift
//  Guardian
//
//  Created by Henry Boswell on 4/15/17.
//  Copyright © 2017 com.project. All rights reserved.
//

import Foundation

import UIKit
import CoreData
import Foundation
import ActionCableClient


class ActionCableController  {
    static let sharedInstance = ActionCableController()

    let client = ActionCableClient(url: URL(string:"wss://guardian-app-v1.herokuapp.com/cable")!)
    //wss://actioncable-echo.herokuapp.com/
    //fathomless-spire-33422.herokuapp.com/

    func initializeActionCable(){
        print("made it here")
        client.connect()
        
        self.client.willConnect = {
            print("Will Connect")
        }
        
        
        self.client.onConnected = {
            print("Connected to \(self.client.url)")
        }
        
        self.client.onDisconnected = {(error: ConnectionError?) in
            print("Disconected with error: \(String(describing: error))")
        }
        
        self.client.willReconnect = {
            print("Reconnecting to \(self.client.url)")
            return true
        }
        let roomChannel = client.create("RoomChannel")
        
        roomChannel.onReceive = { (JSON : Any?, error : Error?) in
            print("Received", JSON ?? "default value", error ?? "default value")
        }
        
        // A channel has successfully been subscribed to.
        roomChannel.onSubscribed = {
            print("Yay!")
        }
        
        // A channel was unsubscribed, either manually or from a client disconnect.
        roomChannel.onUnsubscribed = {
            print("Unsubscribed")
        }
        
        // The attempt at subscribing to a channel was rejected by the server.
        roomChannel.onRejected = {
            print("Rejected")
        }
    }
}
