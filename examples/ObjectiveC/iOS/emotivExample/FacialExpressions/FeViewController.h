//
//  ViewController.h
//  FacialExpressions
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FE_EngineWidget.h"

@interface FeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, FE_EngineWidgetDelegate>
{
    BOOL isTraining;
    MentalAction_t currentAct;
    CGFloat currentPow;
    FE_EngineWidget *engineWidget;
    NSDictionary *dictionaryMentalAction;
    NSMutableDictionary *dictionaryMapping;
    NSString *newAction;
}
@property (weak, nonatomic) IBOutlet UIView *viewMentalCommand;
@property (weak, nonatomic) IBOutlet UIView *viewCube;

@property (weak, nonatomic) IBOutlet UIButton *btClearData;
@property (weak, nonatomic) IBOutlet UIButton *btTraining;
@property (weak, nonatomic) IBOutlet UIButton *btFacialAction;
@property (weak, nonatomic) IBOutlet UIButton *btMentalAction;
@property (weak, nonatomic) IBOutlet UIButton *btSensitivity;

@property (weak, nonatomic) IBOutlet UITableView    *tableFacialAction;
@property (weak, nonatomic) IBOutlet UITableView    *tableMentalAction;

@property (weak, nonatomic) IBOutlet UISlider       *sliderSensitivity;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCenterX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCenterY;

- (IBAction)showFacialTableAction:(UIButton *)sender;
- (IBAction)showMentalTableAction:(UIButton *)sender;
- (IBAction)updateSensitivity:(UIButton *)sender;
- (IBAction)trainingAction:(UIButton *)sender;
- (IBAction)clearData:(UIButton *)sender;
- (IBAction)updateSlider:(UISlider *)sender;
@end

