//
//  Requests.swift
//  FleetRemote
//
//  Created by Matthew Parker on 8/7/14.
//  Copyright (c) 2014 MattParker. All rights reserved.
//

import Foundation

protocol Requester{
    func connectTo(host h:String,port p:Int)
    func services(refresh:Bool,callback:([Service])->Void)
    func statusForService(serviceName: String, callback:(String)->Void)
    func logsForService(serviceName: String, callback:([Log])->Void)
}

var requester:Requester!

class MockRequester: Requester{
    
    private var connected:Bool = false
    let backgroundQueue = NSOperationQueue()
    let mainQueue = NSOperationQueue.mainQueue()
    var host:String = ""
    var port:Int = 0

    
    func connectTo(host h: String, port p: Int) {
        
    }
    
    func services(refresh:Bool, callback:([Service])->Void){
        let servicesOp = self.servicesOperation(callback)
        self.queueOp(servicesOp)
    }
    
    func statusForService(serviceName: String, callback:(String)->Void) {
        let statusOp = self.statusOperation(serviceName, callback)
        self.queueOp(statusOp)
    }
    
    func logsForService(serviceName: String, callback:([Log])->Void){
        let logsOp = self.logsOperation(serviceName,numberOfLines: 10, callback)
        self.queueOp(logsOp)

    }
    
    private func queueOp(op:NSOperation){
        if !self.connected{
            let connectOp = reconnect()
            op.addDependency(connectOp)
        }
        self.backgroundQueue.addOperation(op)
    }
    
    private func connectToOperation(host h:String, port p:Int)->NSOperation{
        let op = NSBlockOperation()
        op.addExecutionBlock({
            self.connected = true
        })
        return op
    }
    
    private func reconnect()->NSOperation{
        let connectOp = self.connectToOperation(host: self.host, port: self.port)
        self.backgroundQueue.addOperation(connectOp)
        return connectOp
    }
    
    private func servicesOperation(callback:([Service])->Void)->NSOperation{
        let op = NSBlockOperation()
        op.addExecutionBlock({
            self.mainQueue.addOperationWithBlock({
                callback([Service(name:"test.service", state:"running")])
            })
        })
        return op
    }
    
    private func statusOperation(serviceName:String,callback:(String)->Void)->NSOperation{
        let op = NSBlockOperation()
        op.addExecutionBlock({
            self.mainQueue.addOperationWithBlock({
                var s = "● myappd.service - MyApp\nLoaded: loaded (/run/fleet/units/myappd.service; linked-runtime)\nActive: active (running) since Thu 2014-08-07 18:37:58 UTC; 1h 29min ago\nProcess: 11569 ExecStartPre=/usr/bin/docker pull busybox (code=exited, status=0/SUCCESS)\nProcess: 11562 ExecStartPre=/usr/bin/docker rm busybox1 (code=exited, status=0/SUCCESS)\nProcess: 11553 ExecStartPre=/usr/bin/docker kill busybox1 (code=exited, status=0/SUCCESS)\nMain PID: 11585 (docker)\nCGroup: /system.slice/myappd.service\n└─11585 /usr/bin/docker run --name busybox1 busybox /bin/sh -c while true; do echo Hello World; sleep 1; done"
                callback(s)

            })
        })
        return op
    }
    
    private func logsOperation(serviceName:String, numberOfLines:Int, callback:([Log])->Void)->NSOperation{
        let op = NSBlockOperation()
        op.addExecutionBlock({
            self.mainQueue.addOperationWithBlock({
                callback([Log(message:"hi")])
            })
        })
        return op
    }
    
}