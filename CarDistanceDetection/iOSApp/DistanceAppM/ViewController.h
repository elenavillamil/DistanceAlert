//
//  ViewController.h
//  DistanceAppM
//
//  Created by Maria Elena Villamil on 10/13/14.
//  Copyright (c) 2014 Maria Elena Villamil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController <BLEDelegate> {
    BLE* m_ble_endpoint;
}

@property (weak, nonatomic) IBOutlet UILabel *DistanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *PersonLabel;

@property bool did_sound_play;

@property bool is_person;
@end
