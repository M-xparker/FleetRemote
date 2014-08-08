//
//  SSHRequestor.swift
//  FleetRemote
//
//  Created by Matthew Parker on 8/8/14.
//  Copyright (c) 2014 MattParker. All rights reserved.
//

import Foundation

class SSHRequestor: Requestor{
    private var connected:Bool = false
    let backgroundQueue = NSOperationQueue()
    let mainQueue = NSOperationQueue.mainQueue()
    var host:String = ""
    var port:Int = 0
    
    private var session:NMSSHSession?
    
    init(){
        
    }
    
    func connectTo(host h: String, port p: Int) {
        self.port = p
        self.host = h
        session = nil
        //        let connectOp = self.connectToOperation(host: h, port: p)
        //        self.backgroundQueue.addOperation(connectOp)
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
    
    func disconnect(){
        if let sesh = self.session{
            sesh.disconnect()
        }
    }
    
    private func queueOp(op:NSOperation){
        if let sesh = self.session{
            if !sesh.connected{
                let connectOp = reconnect()
                op.addDependency(connectOp)
            }
        } else{
            let connectOp = reconnect()
            op.addDependency(connectOp)
        }
        
        self.backgroundQueue.addOperation(op)
    }
    
    private func connectToOperation(host h:String, port p:Int)->NSOperation{
        let op = NSBlockOperation()
        op.addExecutionBlock({
            if h.isEmpty || p == 0{
                op.cancel()
                return
            }
            self.session = NMSSHSession.connectToHost(h, port: p, withUsername: "core")
            if let sesh = self.session{
                if sesh.connected{
                    let keyPath = NSBundle.mainBundle().pathForResource("private_key", ofType: nil)
                    sesh.authenticateByPublicKey(nil, privateKey: keyPath, andPassword: nil)
                    println("last error", sesh.lastError.userInfo)
                    if !sesh.authorized{
                        op.cancel()
                        return
                    }
                    
                }else{
                    op.cancel()
                    return
                }
            }
            
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
            if let sesh = self.session{
                
                if sesh.authorized{
                    var error:NSError?
                    var command = "fleetctl list-units | awk 'NR > 2 { printf(\",\") } BEGIN{printf \"[\"}{if (NR!=1) printf(\"{\\\"unit\\\":\\\"%s\\\",\\\"dstate\\\":\\\"%s\\\",\\\"tmachine\\\":\\\"%s\\\",\\\"state\\\":\\\"%s\\\",\\\"machine\\\":\\\"%s\\\",\\\"active\\\":\\\"%s\\\"}\", $1, $2, $3, $4, $5, $6) }END{print \"]\"}'"
                    let result = sesh.channel.execute(command, error: &error)
                    self.mainQueue.addOperationWithBlock({
                        var resp: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), options: NSJSONReadingOptions.MutableContainers, error: &error) as Array<NSDictionary>
                        
                        var s:[Service] = []
                        for dict in resp{
                            s.append(Service(dict:dict))
                        }
                        callback(s)
                        
                        if let err = error{
                            println(err.userInfo)
                        }
                    })
                    
                }
            }
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