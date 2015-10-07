//
//  ViewController.swift
//  MentalCommand
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2013 EmotivLifeSciences. All rights reserved.
//

import UIKit

class ViewController: UIViewController, EngineWidgetDelegate {

    @IBOutlet weak var viewMentalCommand: UIView!
    @IBOutlet weak var viewPowerBar: UIView!
    @IBOutlet weak var viewPower: UIView!
    @IBOutlet weak var viewCube: UIView!
    
    @IBOutlet weak var labelSkillRating: UILabel!
    
    @IBOutlet weak var btClearData: UIButton!
    @IBOutlet weak var btTraining: UIButton!
    @IBOutlet weak var btAction: UIButton!
    
    @IBOutlet weak var tableAction: UITableView!
    
    @IBOutlet weak var constraintPower: NSLayoutConstraint!
    @IBOutlet weak var constraintCenterX: NSLayoutConstraint!
    @IBOutlet weak var constraintCenterY: NSLayoutConstraint!
    
    var dictionaryAction : [String:MentalAction_enum] = ["Neutral":Mental_Neutral, "Push":Mental_Push, "Pull":Mental_Push, "Left":Mental_Left, "Right":Mental_Right, "Lift":Mental_Lift, "Drop":Mental_Drop]
    
    let engineWidget: EngineWidget = EngineWidget()
    
    var currentPow: CGFloat!
    var currentAct: MentalAction_t!
    var isTraining: Bool!
    
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
    
    @IBAction func showTableAction(sender: UIButton) {
        self.tableAction.hidden = !self.tableAction.hidden
    }
    
    
    @IBAction func trainingAction(sender: UIButton) {
        if !isTraining
        {
            let action = dictionaryAction[self.btAction.titleForState(UIControlState.Normal)!]
            engineWidget.setActiveAction(action!)
            engineWidget.setTrainingAction(action!)
            engineWidget.setTrainingControl(Mental_Start)
            isTraining = true
        }
    }
    
    @IBAction func clearData(sender: UIButton) {
        let action = dictionaryAction[self.btAction.titleForState(UIControlState.Normal)!]
        engineWidget.clearTrainingData(action!)
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

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionaryAction.keys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cellString")
        cell.textLabel?.text = Array(dictionaryAction.keys)[indexPath.row]
        let action = dictionaryAction[Array(dictionaryAction.keys)[indexPath.row]]
        if engineWidget.isActionTrained(action!)
        {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableAction.hidden = true
        self.btAction.setTitle(Array(dictionaryAction.keys)[indexPath.row], forState: UIControlState.Normal)
        
        let action = dictionaryAction[Array(dictionaryAction.keys)[indexPath.row]]
        self.labelSkillRating.text = "SkillRating: \(engineWidget.getSkillRating(action!))%"
    }
}

extension ViewController {
    func emoStateUpdate(currentAction: MentalAction_t, power currentPower: Float)
    {
        currentAct = currentAction
        currentPow = CGFloat(currentPower)
        self.constraintPower.constant = self.viewPowerBar.frame.height * CGFloat(currentPower)
        UIView.animateWithDuration(0.1, animations: ({
            self.viewPower.layoutIfNeeded()
//            println("power \(currentPower) \(self.constraintPower.constant)")
        }))
    }
    
    func onMentalCommandTrainingStarted() {
        
    }
    
    func onMentalCommandTrainingCompleted() {
        isTraining = false
        let alert = UIAlertController(title: "Training Completed", message: "Action was trained completed", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        self.tableAction.reloadData()
    }
    
    func onMentalCommandTrainingSuccessed() {
        let alert = UIAlertController(title: "Training Successed", message: "Do you want to accept this training?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Reject", style: UIAlertActionStyle.Default, handler: { action in
            self.engineWidget.setTrainingControl(Mental_Reject)
        }))
        alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: { action in
            self.engineWidget.setTrainingControl(Mental_Accept)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func onMentalCommandTrainingFailed() {
        isTraining = false;
    }
    
    func onMentalCommandTrainingDataErased() {
        let alert = UIAlertController(title: "Erase Completed", message: "Action was erased completed", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        self.tableAction.reloadData()
    }
    
    func onMentalCommandTrainingRejected() {
        isTraining = false;
    }
    
    func onMentalCommandTrainingSignatureUpdated() {
        self.tableAction.reloadData()
    }
}


