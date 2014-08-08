//
//  Log.swift
//  FleetRemote
//
//  Created by Matthew Parker on 8/7/14.
//  Copyright (c) 2014 MattParker. All rights reserved.
//

import Foundation

struct Log{
    var month = "Aug"
    var day = "07"
    var time = "16:48.0345"
    var host = "core-02"
    var message = ""
    
    init(message:String){
        self.message = message
    }
    init(dict:NSDictionary){
        self.month = dict["month"] as String
        self.day = dict["day"] as String
        self.time = dict["time"] as String
        self.host = dict["host"] as String
        self.message = dict["log"] as String
    }
}