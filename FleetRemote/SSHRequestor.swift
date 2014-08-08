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
    var username:String = ""
    
    private var session:NMSSHSession?
    
    init(){
        
    }
    
    func connectTo(host h: String, port p: Int, username u:String) {
        self.port = p
        self.host = h
        self.username = u
        session = nil
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
                println("not connected")
                let connectOp = reconnect()
                op.addDependency(connectOp)
            }
        } else{
            println("no sesh")
            let connectOp = reconnect()
            op.addDependency(connectOp)
        }
        
        self.backgroundQueue.addOperation(op)
    }
    
    private func connectToOperation(host h:String, port p:Int, username u:String)->NSOperation{
        let op = NSBlockOperation()
        op.addExecutionBlock({
            if h.isEmpty || p == 0{
                op.cancel()
                return
            }
            self.session = NMSSHSession.connectToHost(h, port: p, withUsername: u)
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
        let connectOp = self.connectToOperation(host: self.host, port: self.port, username: self.username)
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
                    var resp: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), options: NSJSONReadingOptions.MutableContainers, error: &error) as Array<NSDictionary>
                    
                    var s:[Service] = []
                    for dict in resp{
                        s.append(Service(dict:dict))
                    }
                    self.mainQueue.addOperationWithBlock({
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
            if let sesh = self.session{
                
                if sesh.authorized{
                    var error:NSError?
                    var command = "fleetctl status " + serviceName + " | awk '{if(NR<10)print($0)}'"
                    let result = sesh.channel.execute(command, error: &error)
                    self.mainQueue.addOperationWithBlock({
                        callback(result)
                        if let err = error{
                            println(err.userInfo)
                        }
                    })
                    
                }
            }
        })
        return op
    }
    
    private func logsOperation(serviceName:String, numberOfLines:Int, callback:([Log])->Void)->NSOperation{
        let op = NSBlockOperation()
        op.addExecutionBlock({
            if let sesh = self.session{
                
                if sesh.authorized{
                    var error:NSError?
                    var command = "fleetctl journal " + serviceName + " | awk 'NR > 2 { printf(\",\") }BEGIN{printf \"[\"} NR > 1{printf(\"{\\\"month\\\":\\\"%s\\\",\\\"day\\\":\\\"%s\\\",\\\"time\\\":\\\"%s\\\",\\\"host\\\":\\\"%s\\\",\\\"log\\\":\\\"\",$1,$2,$3,$4);$1=$2=$3=$4=$5=\"\";gsub(/\\r/,\"\",$0);sub(/     /,\"\");printf(\"%s\\\"}\",$0)}END{printf \"]\"}'"
                    let result = sesh.channel.execute(command, error: &error)
                    var resp: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), options: NSJSONReadingOptions.MutableContainers, error: &error) as Array<NSDictionary>
                    
                    var s:[Log] = []
                    for dict in resp{
                        s.append(Log(dict:dict))
                    }
                    self.mainQueue.addOperationWithBlock({
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
}