//
//  MainViewController.h
//  EEGLogger
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2015 EmotivLifeSciences. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <edk_ios/Iedk.h>

@interface MainViewController : UIViewController{
    IBOutlet UIButton *btn_ble;
    IBOutlet UIButton *btn_stop;
    
    EmoEngineEventHandle eEvent			;
	EmoStateHandle emoState				;
    DataHandle     hData                ;
    NSString       *documentDirectory   ;
	unsigned int userid					;
	int state  ;
    BOOL lock   ;
    BOOL isConnectBLE;
    BOOL connected;
    BOOL readytocollect;
}
-(IBAction)ConnectWithBLE:(id)sender;
-(IBAction)StopClick:(id)sender;
@end
