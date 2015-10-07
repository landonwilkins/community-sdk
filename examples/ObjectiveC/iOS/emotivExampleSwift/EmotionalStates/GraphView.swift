//
//  GraphView.swift
//  emotivExampleSwift
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2013 EmotivLifeSciences. All rights reserved.
//

import UIKit

class GraphView: UIView {

    var graph : CpLineGraphView = CpLineGraphView()
    
    init(frame: CGRect, number:Int) {
        super.init(frame: frame)
        let array : [String] = ["Engagement", "Relax", "Longterm Excitement", "Instantaneous Excitement"]
        
        graph = CpLineGraphView(frame: CGRectMake(0, 5, self.frame.width + 20, self.frame.height + 10), indexGraph: Int32(number))
        self.addSubview(graph)
        
        var viewBanner : UIView! = UIView(frame: CGRectMake(0, 5, self.frame.width + 20, 40))
        switch (number) {
        case 0:
            viewBanner.backgroundColor = UIColor(red:41.0/255.0, green:171.0/255.0, blue:247.0/255.0, alpha:1.0)
            break;
        case 1:
            viewBanner.backgroundColor = UIColor.greenColor()
            break;
        case 2:
            viewBanner.backgroundColor = UIColor.redColor()
            break;
        case 3:
            viewBanner.backgroundColor = UIColor.orangeColor()
            break;
        default:
            break;
        }
        
        var label : UILabel! = UILabel(frame: CGRectMake(10, 10, 200, 20))
        label.text = array[number];
        label.textColor = UIColor.whiteColor();
        viewBanner.addSubview(label)
        self.addSubview(viewBanner)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func updateValue(value : CGFloat)  {
        graph.updateValue(Float(value))
    }

}
