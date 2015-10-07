//
//  ViewController.h
//  MentalCommand
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EngineWidget.h"

@interface McViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, EngineWidgetDelegate, UIAlertViewDelegate>
{
    BOOL isTraining;
    MentalAction_t currentAct;
    CGFloat currentPow;
    EngineWidget *engineWidget;
    NSDictionary *dictionaryAction;
}
@property (weak, nonatomic) IBOutlet UIView *viewMentalCommand;
@property (weak, nonatomic) IBOutlet UIView *viewPowerBar;
@property (weak, nonatomic) IBOutlet UIView *viewPower;
@property (weak, nonatomic) IBOutlet UIView *viewCube;

@property (weak, nonatomic) IBOutlet UILabel *labelSkillRating;

@property (weak, nonatomic) IBOutlet UIButton *btClearData;
@property (weak, nonatomic) IBOutlet UIButton *btTraining;
@property (weak, nonatomic) IBOutlet UIButton *btAction;

@property (weak, nonatomic) IBOutlet UITableView *tableAction;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPower;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCenterX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCenterY;

- (IBAction)showTableAction:(UIButton *)sender;
- (IBAction)trainingAction:(UIButton *)sender;
- (IBAction)clearData:(UIButton *)sender;
@end

