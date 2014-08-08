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
    
    init(name:String, state:String){
        self.name = name
        self.state = state
    }
    init(){
        
    }
}
