//
//  Service.swift
//  FleetRemote
//
//  Created by Matthew Parker on 8/7/14.
//  Copyright (c) 2014 MattParker. All rights reserved.
//

import Foundation

struct Service{
    var name:String = ""
    var machine:String = ""
    var ipAddress:String = ""
    var state:String = ""
    var active:String = ""
    
    init(name:String, state:String){
        self.name = name
        self.state = state
    }
    init(){
        
    }
    init(dict:NSDictionary){
        self.name = dict["unit"] as String
        self.machine = dict["machine"] as String
        self.state = dict["state"] as String
        self.active = dict["active"] as String
    }
}
