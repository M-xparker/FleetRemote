//
//  StatusViewController.swift
//  FleetRemote
//
//  Created by Matthew Parker on 8/8/14.
//  Copyright (c) 2014 MattParker. All rights reserved.
//

import UIKit

class StatusViewController:UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var service = Service()
    var status:String = ""
    var logs:[Log] = []
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = service.name
        requester.statusForService(service.name, self.updateStatus)
        
        self.tableView.registerClass(LogCell.self, forCellReuseIdentifier: LogCell.CellIdentifier())
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        CoreOS.style(self.startButton,self.stopButton)
        self.startButton.backgroundColor = UIColor.coreosBlue()
        self.stopButton.backgroundColor = UIColor.coreosRed()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func updateStatus(status:String){
        self.status = status
        self.statusLabel.text = self.status
        requester.logsForService(service.name, callback: self.updateLogs)
    }
    func updateLogs(logs:[Log]){
        self.logs = logs
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TableView DataSource
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.logs.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:LogCell = self.tableView.dequeueReusableCellWithIdentifier(LogCell.CellIdentifier()) as LogCell
        
        cell.monthLabel.text = self.logs[indexPath.row].month
        cell.dayLabel.text = self.logs[indexPath.row].day
        cell.timeLabel.text = self.logs[indexPath.row].time
        cell.message.text = self.logs[indexPath.row].message
        
        return cell
    }
    
    //MARK: TableView Delegate
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
    }
}

class LogCell:UITableViewCell{
    var monthLabel = UILabel()
    var dayLabel = UILabel()
    var timeLabel = UILabel()
    var message = UILabel()
    
    class func CellIdentifier()->String{
        return "LogCell"
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        CoreOS.style(self.monthLabel,self.dayLabel,self.timeLabel,self.message)
        self.monthLabel.frame = CGRectMake(20, 0, 30, self.contentView.frame.size.height)
        self.monthLabel.textAlignment = NSTextAlignment.Center
        self.dayLabel.frame = CGRectMake(self.monthLabel.frame.origin.x + self.monthLabel.frame.size.width, 0, 20, self.contentView.frame.size.height)
        self.dayLabel.textAlignment = NSTextAlignment.Center
        self.timeLabel.frame = CGRectMake(self.dayLabel.frame.origin.x + self.dayLabel.frame.size.width+5, 0, 45, self.contentView.frame.size.height)
        self.message.frame = CGRectMake(self.timeLabel.frame.origin.x + self.timeLabel.frame.size.width+20, 0, self.contentView.frame.size.width - self.timeLabel.frame.origin.x + self.timeLabel.frame.size.width+20 - 40, self.contentView.frame.size.height)
        self.accessoryType = UITableViewCellAccessoryType.DetailButton
        
        self.addSubviews(self.monthLabel,self.dayLabel,self.timeLabel,self.message)
        
    }
}