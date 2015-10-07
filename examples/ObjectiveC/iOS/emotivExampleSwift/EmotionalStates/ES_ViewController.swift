//
//  ViewController.swift
//  EmotionalStates
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2013 EmotivLifeSciences. All rights reserved.
//

import UIKit

class ES_ViewController: UIViewController, ES_EngineWidgetDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btRecord: UIButton!
    
    var arrayView : [GraphView] = []
    let engineWidget = ES_EngineWidget()
    var isRecording : Bool = false
    var filePath :  String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        engineWidget.delegate = self
        
        for var i = 0; i < 4; i++
        {
            let y = 200 * i
            let view : GraphView! = GraphView(frame: CGRectMake(0, CGFloat(y)-5, self.view.frame.width, 200), number: i)
            self.scrollView.addSubview(view)
            arrayView.append(view)
            //[arrayView addObject:view];
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        self.scrollView.contentSize = CGSizeMake(self.view.frame.width, 800)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func recordData(sender: AnyObject) {
        if(!isRecording)
        {
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            filePath = paths[0].stringByAppendingPathComponent("affectiv.csv");
            if(NSFileManager.defaultManager().fileExistsAtPath(filePath))
            {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(self.filePath)
                } catch {
                    // ...
                }
            }
            NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
            self.btRecord.setTitle("Stop", forState: UIControlState.Normal)
        }
        else
        {
            self.btRecord.setTitle("Record", forState: UIControlState.Normal)
        }
        isRecording = !isRecording;
    }
    
    func emoStateUpdate(arrayScore: [AnyObject]!)
    {
        for var i = 0; i < arrayScore.count ; i++
        {
            let view : GraphView! = arrayView[i]
            view.updateValue(CGFloat(arrayScore[i] as! NSNumber));
        }
        writeData(arrayScore)
    }
    
    func writeData(array: [AnyObject]!)
    {
        if isRecording
        {
            var data : String = "\(array[0])"
            for var i = 1; i < array.count; i++
            {
                data = data.stringByAppendingString("\(array[i])")
            }
            data = data.stringByAppendingString("\n")
            let fh : NSFileHandle = NSFileHandle(forWritingAtPath: filePath)!
            fh.seekToEndOfFile()
            fh.writeData(data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            fh.closeFile()
        }
    }
}

