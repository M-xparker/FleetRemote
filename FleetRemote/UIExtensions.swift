//
//  CustomColors.swift
//  FleetRemote
//
//  Created by Matthew Parker on 8/8/14.
//  Copyright (c) 2014 MattParker. All rights reserved.
//

import UIKit

extension UIColor{
    class func coreosBlue()->UIColor{
        return UIColor(red: 63/255, green: 156/255, blue: 217/255, alpha: 1.0)
    }
    class func coreosRed()->UIColor{
        return UIColor(red: 240/255, green: 76/255, blue: 92/255, alpha: 1.0)
    }
}

extension UIView{
    func addSubviews(views:UIView...){
        for view in views{
            self.addSubview(view)
        }
    }
}


class CoreOS{
    class func radius()->CGFloat{
        return 2
    }
    class func style(buttons:UIButton...){
        for button in buttons{
            button.layer.cornerRadius = self.radius()
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.titleLabel.font = self.fontWithSize(14)
        }
    }
    class func style(fields:UITextField...){
        for field in fields{
            field.layer.cornerRadius = self.radius()
            field.font = self.fontWithSize(14)
        }
    }
    class func style(labels:UILabel...){
        for label in labels{
            label.layer.cornerRadius = self.radius()
            label.font = self.fontWithSize(14)
        }
    }
    class func fontWithSize(size:CGFloat)->UIFont{
        return UIFont(name:"SourceSansPro-Regular", size:size)
    }
    class func fontBoldWithSize(size:CGFloat)->UIFont{
        return UIFont(name:"SourceSansPro-Bold", size:size)
    }
}