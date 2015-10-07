//
//  ViewController.m
//  FacialExpressions
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import "FeViewController.h"

@interface FeViewController ()

@end

@implementation FeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    engineWidget = [[FE_EngineWidget alloc] init];
    engineWidget.delegate = self;
    
    currentPow = 0.0f;
    currentAct = Mental_Neutral;
    isTraining = false;
    
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateCubePosition) userInfo:nil repeats:YES];
    [timer fire];
    
    dictionaryMentalAction = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:Mental_Neutral], @"Neutral", [NSNumber numberWithInt:Mental_Push], @"Push", [NSNumber numberWithInt:Mental_Pull], @"Pull", [NSNumber numberWithInt:Mental_Left], @"Left", [NSNumber numberWithInt:Mental_Right], @"Right", [NSNumber numberWithInt:Mental_Lift], @"Lift", [NSNumber numberWithInt:Mental_Drop], @"Drop", nil];
    
    dictionaryMapping = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Neutral", @"Neutral", @"Push", @"Smile", @"Pull", @"Clench", nil];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showFacialTableAction:(UIButton *)sender {
    self.tableMentalAction.hidden = true;
    self.sliderSensitivity.hidden = true;
    self.tableFacialAction.hidden = !self.tableFacialAction.hidden;
}

- (void)showMentalTableAction:(UIButton *)sender {
    self.tableFacialAction.hidden = true;
    self.sliderSensitivity.hidden = true;
    self.tableMentalAction.hidden = !self.tableMentalAction.hidden;
}

- (void)updateSensitivity:(UIButton *)sender {
    self.tableMentalAction.hidden = true;
    self.tableFacialAction.hidden = true;
    self.sliderSensitivity.hidden = !self.sliderSensitivity.hidden;
}

- (void)updateSlider:(UISlider *)sender {
    NSString * action = self.btFacialAction.currentTitle;
    [self.btSensitivity setTitle:[NSString stringWithFormat:@"%1.0f", self.sliderSensitivity.value] forState: UIControlStateNormal];
    [engineWidget setSensitivity:action value:(int)self.sliderSensitivity.value];
}

- (IBAction)trainingAction:(UIButton *)sender {
    if(!isTraining)
    {
        [engineWidget setTrainingAction:self.btFacialAction.currentTitle];
        [engineWidget setTrainingControl:Facial_Start];
        isTraining = true;
    }
}

- (IBAction)clearData:(UIButton *)sender {
    [engineWidget clearTrainingData:self.btFacialAction.currentTitle];
}

-(void) updateCubePosition {
    [UIView animateWithDuration:0.2 animations:^{
        float range = currentPow * 4;
        
        //move cube to left or right direction
        if((currentAct == Mental_Left || currentAct == Mental_Right) && range > 0)
        {
            self.constraintCenterX.constant = currentAct == Mental_Left ? MIN(70, self.constraintCenterX.constant + range) : MAX(-70, self.constraintCenterX.constant - range);
        }
        else if(self.constraintCenterX.constant != 0)
        {
            self.constraintCenterX.constant = self.constraintCenterX.constant > 0 ? MAX(0, self.constraintCenterX.constant - 4) : MIN(0, self.constraintCenterX.constant + 4);
        }
        
        //move cube to up or down direction
        if ((currentAct == Mental_Lift || currentAct == Mental_Drop) && range > 0)
        {
            self.constraintCenterY.constant = currentAct == Mental_Lift ? MIN(70, self.constraintCenterY.constant + range) : MAX(-70, self.constraintCenterY.constant - range);
        }
        else if(self.constraintCenterY.constant != 0)
        {
            self.constraintCenterY.constant = self.constraintCenterY.constant > 0 ? MAX(0, self.constraintCenterY.constant - 4) : MIN(0, self.constraintCenterY.constant + 4);
        }
        
        //move cube to forward or backward direction
        if ((currentAct == Mental_Pull || currentAct == Mental_Push) && range > 0)
        {
            self.viewCube.transform = currentAct == Mental_Push ? CGAffineTransformScale(CGAffineTransformIdentity, MAX(0.3, self.viewCube.transform.a - currentPow/4), MAX(0.3, self.viewCube.transform.d - currentPow/4)) : CGAffineTransformScale(CGAffineTransformIdentity, MIN(2.3, self.viewCube.transform.a + currentPow/4), MIN(2.3, self.viewCube.transform.d + currentPow/4));
        }
        else if (self.viewCube.transform.a != 1)
        {
            float scale = self.viewCube.transform.a < 1 ? 0.05 : -0.05;
            self.viewCube.transform = CGAffineTransformScale(CGAffineTransformIdentity, MAX(1, self.viewCube.transform.a + scale), MAX(1, self.viewCube.transform.d + scale));
        }
    }];
}

#pragma mark UITableView
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == self.tableFacialAction)
    {
        return dictionaryMapping.allKeys.count;
    }
    else
    {
        return dictionaryMentalAction.allKeys.count;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellString"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellString"];
    }
    if(tableView == self.tableFacialAction)
    {
        cell.textLabel.text = [dictionaryMapping.allKeys objectAtIndex:indexPath.row];
        if([engineWidget isActionTrained:[dictionaryMapping.allKeys objectAtIndex:indexPath.row]])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else
    {
        cell.textLabel.text = [dictionaryMentalAction.allKeys objectAtIndex:indexPath.row];
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tableFacialAction)
    {
        self.tableFacialAction.hidden = true;
        [self.btFacialAction setTitle:[dictionaryMapping.allKeys objectAtIndex:indexPath.row] forState: UIControlStateNormal];
        NSString * action = [dictionaryMapping objectForKey:[dictionaryMapping.allKeys objectAtIndex:indexPath.row]];
        [self.btMentalAction setTitle:action forState: UIControlStateNormal];
        int value = [engineWidget getSensitivity:[dictionaryMapping.allKeys objectAtIndex:indexPath.row]];
        [self.btSensitivity setTitle:[NSString stringWithFormat:@"%d", value] forState: UIControlStateNormal];
        [self.sliderSensitivity setValue:value animated:YES];
    }
    else
    {
        self.tableMentalAction.hidden = true;
        newAction = [dictionaryMentalAction.allKeys objectAtIndex:indexPath.row];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:[NSString stringWithFormat:@"Do you want map %@ to %@", newAction, self.btFacialAction.currentTitle] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alert setDelegate:self];
        alert.tag = 3;
        [alert show];
    }
}

#pragma mark EngineWidget Delegate
-(void) updateLowerFaceAction:(NSString *)currentAction power:(float)power {
    currentAct = (MentalAction_t)[dictionaryMentalAction[dictionaryMapping[currentAction]] integerValue];
    currentPow = power;
}

-(void) onFacialExpressionTrainingStarted {
    
}

-(void) onFacialExpressionTrainingCompleted {
    isTraining = false;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Training Completed" message:@"Action was trained completed" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [self.tableFacialAction reloadData];
}

-(void) onFacialExpressionTrainingSuccessed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Training Successed" message:@"Do you want to accept this training?" delegate:self cancelButtonTitle:@"Reject" otherButtonTitles:@"Accept", nil];
    [alert setDelegate:self];
    [alert show];
}

-(void) onFacialExpressionTrainingFailed {
    isTraining = false;
}

-(void) onFacialExpressionTrainingDataErased {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erase Completed" message:@"Action was erased completed" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [self.tableFacialAction reloadData];
}

-(void) onFacialExpressionTrainingRejected {
    isTraining = false;
}

-(void) onFacialExpressionTrainingSignatureUpdated {
    [self.tableFacialAction reloadData];
}

#pragma mark UIAlertView
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 1:
            if(alertView.tag == 3)
            {
                [dictionaryMapping setObject:newAction forKey:@"Smile"];
                [self.btMentalAction setTitle:newAction forState:UIControlStateNormal];
            }
            else
                [engineWidget setTrainingControl:Facial_Accept];
            break;
        case 0:
            if(alertView.tag == 3)
                ;
            else
                [engineWidget setTrainingControl:Facial_Reject];
            break;
        default:
            break;
    }
}
@end
