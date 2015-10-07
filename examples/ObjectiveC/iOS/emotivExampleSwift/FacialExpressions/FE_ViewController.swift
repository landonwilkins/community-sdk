//
//  ViewController.swift
//  FacialExpressions
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2013 EmotivLifeSciences. All rights reserved.
//

import UIKit

class FE_ViewController: UIViewController, FE_EngineWidgetDelegate {

    @IBOutlet weak var viewFacialExpression: UIView!
    @IBOutlet weak var viewCube: UIView!
    
    @IBOutlet weak var btClearData: UIButton!
    @IBOutlet weak var btTraining: UIButton!
    @IBOutlet weak var btFacialAction: UIButton!
    @IBOutlet weak var btMentalAction: UIButton!
    @IBOutlet weak var btSensitivity: UIButton!

    @IBOutlet weak var tableFacialAction: UITableView!
    @IBOutlet weak var tableMentalAction: UITableView!

    @IBOutlet weak var sliderSensitivity: UISlider!
    @IBOutlet weak var constraintCenterX: NSLayoutConstraint!
    @IBOutlet weak var constraintCenterY: NSLayoutConstraint!
    
    var dictionaryMentalAction : [String:MentalAction_enum] = ["Neutral":Mental_Neutral, "Push":Mental_Push, "Pull":Mental_Push, "Left":Mental_Left, "Right":Mental_Right, "Lift":Mental_Lift, "Drop":Mental_Drop]
    
    var dictionaryMapping : [String:String] = ["Neutral":"Neutral", "Smile":"Push", "Clench":"Right"]
    
    var currentPow: CGFloat!
    var currentAct: MentalAction_t!
    var isTraining: Bool!

    let engineWidget: FE_EngineWidget = FE_EngineWidget()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        engineWidget.delegate = self
        btTraining.layer.borderColor = UIColor.whiteColor().CGColor
        
        currentPow = 0.0
        currentAct = Mental_Neutral
        isTraining = false

        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateCubePosition"), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showFacialTableAction(sender: UIButton) {
        self.tableMentalAction.hidden = true
        self.sliderSensitivity.hidden = true;
        self.tableFacialAction.hidden = !self.tableFacialAction.hidden
        
    }
    
    @IBAction func showMentalTableAction(sender: UIButton) {
        self.tableFacialAction.hidden = true
        self.sliderSensitivity.hidden = true;
        self.tableMentalAction.hidden = !self.tableMentalAction.hidden
    }
    
    @IBAction func updateSensitivity(sender: UIButton) {
        self.tableFacialAction.hidden = true
        self.tableMentalAction.hidden = true
        self.sliderSensitivity.hidden = !self.sliderSensitivity.hidden
    }
    
    @IBAction func trainingAction(sender: UIButton) {
        if !isTraining
        {
            let action = self.btFacialAction.titleForState(UIControlState.Normal)!
            engineWidget.setTrainingAction(action)
            engineWidget.setTrainingControl(Facial_Start)
            isTraining = true
        }
    }
    
    @IBAction func clearData(sender: UIButton) {
        let action = self.btFacialAction.titleForState(UIControlState.Normal)
        engineWidget.clearTrainingData(action)
    }
    
    @IBAction func updateSlider(sender: AnyObject) {
        let action = self.btFacialAction.titleForState(UIControlState.Normal)
        self.btSensitivity.setTitle("\(Int32(self.sliderSensitivity.value))", forState: UIControlState.Normal)
        engineWidget.setSensitivity(action, value: Int32(self.sliderSensitivity.value))
    }
    
    func updateCubePosition() {
        
        UIView.animateWithDuration(0.2, animations: ({
            let range = self.currentPow * 4
            
            //move cube to left or right direction
            if (self.currentAct.rawValue == Mental_Left.rawValue || self.currentAct.rawValue == Mental_Right.rawValue) && range > 0
            {
                self.constraintCenterX.constant = self.currentAct.rawValue == Mental_Left.rawValue ? min(70, self.constraintCenterX.constant + range) : max(-70, self.constraintCenterX.constant - range)
            }
            else if self.constraintCenterX.constant != 0
            {
                self.constraintCenterX.constant = self.constraintCenterX.constant > 0 ? max(0, self.constraintCenterX.constant - 4) : min(0, self.constraintCenterX.constant + 4)
            }
            
            //move cube to up or down direction
            if (self.currentAct.rawValue == Mental_Lift.rawValue || self.currentAct.rawValue == Mental_Drop.rawValue) && range > 0
            {
                self.constraintCenterY.constant = self.currentAct.rawValue == Mental_Lift.rawValue ? min(70, self.constraintCenterY.constant + range) : max(-70, self.constraintCenterY.constant - range)
            }
            else if self.constraintCenterY.constant != 0
            {
                self.constraintCenterY.constant = self.constraintCenterY.constant > 0 ? max(0, self.constraintCenterY.constant - 4) : min(0, self.constraintCenterY.constant + 4)
            }
            
            //move cube to forward or backward direction
            if (self.currentAct.rawValue == Mental_Pull.rawValue || self.currentAct.rawValue == Mental_Push.rawValue) && range > 0
            {
                self.viewCube.transform = self.currentAct.rawValue == Mental_Push.rawValue ? CGAffineTransformScale(CGAffineTransformIdentity, max(0.3, self.viewCube.transform.a - self.currentPow/4), max(0.3, self.viewCube.transform.d - self.currentPow/4)) : CGAffineTransformScale(CGAffineTransformIdentity, min(2.3, self.viewCube.transform.a + self.currentPow/4), min(2.3, self.viewCube.transform.d + self.currentPow/4))
            }
            else if self.viewCube.transform.a != 1
            {
                let scale : CGFloat! = self.viewCube.transform.a < 1 ? 0.05 : -0.05
                self.viewCube.transform = CGAffineTransformScale(CGAffineTransformIdentity, max(1, self.viewCube.transform.a + scale), max(1, self.viewCube.transform.d + scale))
            }
        }))
    }
}

extension FE_ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableFacialAction
        {
            return dictionaryMapping.keys.count
        }
        else
        {
            return dictionaryMentalAction.keys.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cellString")
        if tableView == self.tableFacialAction
        {
            cell.textLabel?.text = Array(dictionaryMapping.keys)[indexPath.row]
            if engineWidget.isActionTrained(Array(dictionaryMapping.keys)[indexPath.row])
            {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        else
        {
            cell.textLabel?.text = Array(dictionaryMentalAction.keys)[indexPath.row]
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.tableFacialAction
        {
            self.tableFacialAction.hidden = true
            self.btFacialAction.setTitle(Array(dictionaryMapping.keys)[indexPath.row], forState: UIControlState.Normal)
            let action = dictionaryMapping[Array(dictionaryMapping.keys)[indexPath.row]]
            self.btMentalAction.setTitle(action, forState: UIControlState.Normal)
            let value = engineWidget.getSensitivity(Array(dictionaryMapping.keys)[indexPath.row])
            btSensitivity.setTitle("\(value)", forState: UIControlState.Normal)
            sliderSensitivity.setValue(Float(value), animated: true)
        }
        else
        {
            self.tableMentalAction.hidden = true
            let newAction = Array(self.dictionaryMentalAction.keys)[indexPath.row]
            let alert = UIAlertController(title: "Message", message:"Do you want map \(newAction) to " + self.btFacialAction.currentTitle! , preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler:nil))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ action in
                self.dictionaryMapping[self.btFacialAction.currentTitle!] = newAction
                self.btMentalAction.setTitle(newAction, forState: UIControlState.Normal)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension FE_ViewController {
    
    func updateLowerFaceAction(currentAction: String!, power: Float) {
        currentAct = dictionaryMentalAction[dictionaryMapping[currentAction]!]
        currentPow = CGFloat(power)
    }
    
    func onFacialExpressionTrainingStarted() {
        
    }
    
    func onFacialExpressionTrainingCompleted() {
        isTraining = false
        let alert = UIAlertController(title: "Training Completed", message: "Action was trained completed", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        self.tableFacialAction.reloadData()
    }
    
    func onFacialExpressionTrainingSuccessed() {
        let alert = UIAlertController(title: "Training Successed", message: "Do you want to accept this training?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Reject", style: UIAlertActionStyle.Default, handler: { action in
            self.engineWidget.setTrainingControl(Facial_Reject)
        }))
        alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: { action in
            self.engineWidget.setTrainingControl(Facial_Accept)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func onFacialExpressionTrainingFailed() {
        isTraining = false;
    }
    
    func onFacialExpressionTrainingDataErased() {
        let alert = UIAlertController(title: "Erase Completed", message: "Action was erased completed", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        self.tableFacialAction.reloadData()
    }
    
    func onFacialExpressionTrainingRejected() {
        isTraining = false;
    }
    
    func onFacialExpressionTrainingSignatureUpdated() {
        self.tableFacialAction.reloadData()
    }
}

