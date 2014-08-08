//
//  ViewController.swift
//  FleetRemote
//
//  Created by Matthew Parker on 8/7/14.
//  Copyright (c) 2014 MattParker. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
                            
    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var portField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var services:[Service]=[]
    
    @IBAction func updatePressed(sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "FleetRemote"

        CoreOS.style(self.hostField, self.portField)
        CoreOS.style(self.updateButton)
        self.updateButton.backgroundColor = UIColor.coreosBlue()
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.coreosRed()
        self.tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        
        self.tableView.registerClass(ServiceCell.self, forCellReuseIdentifier: "cell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        requester.services(false, self.updateServices)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateServices(services:[Service]){
        self.services = services
        self.tableView.reloadData()
    }
    
    func refresh(){
        requester.services(true, self.updateServices)
    }
    
    //MARK: TableView DataSource
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.services.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:ServiceCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as ServiceCell
        
        cell.serviceLabel.text = self.services[indexPath.row].name
        cell.stateLabel.text = self.services[indexPath.row].state
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

        return cell
    }
    
    //MARK: TableView Delegate
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let vc:StatusViewController = self.storyboard.instantiateViewControllerWithIdentifier("StatusViewController") as StatusViewController
        vc.service = self.services[indexPath.row]
        self.navigationController.pushViewController(vc, animated: true)
        var cell = self.tableView.cellForRowAtIndexPath(indexPath)
        cell.selected = false
        
    }
}

//MARK: ServiceCell

class ServiceCell:UITableViewCell{
    var serviceLabel:UILabel = UILabel()
    var stateLabel:UILabel = UILabel()
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        CoreOS.style(self.serviceLabel,self.stateLabel)
        
        self.serviceLabel.frame = CGRectMake(20, 0, 100, self.contentView.frame.size.height)
        self.stateLabel.frame = CGRectMake(self.contentView.frame.size.width - 90, 0, 50, self.contentView.frame.size.height)
        self.stateLabel.textAlignment = NSTextAlignment.Right
        self.contentView.addSubview(self.serviceLabel)
        self.contentView.addSubview(self.stateLabel)
        
    }
}

