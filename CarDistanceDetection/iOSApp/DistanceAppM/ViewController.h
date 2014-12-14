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
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <BLEDelegate> {
    BLE* m_ble_endpoint;
}

@property (weak, nonatomic) IBOutlet UILabel *DistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *PersonLabel;

@property (strong, nonatomic) NSDictionary *detectorOptions;
@property (strong, nonatomic) CIDetector *face_detector;
@property (strong, nonatomic) NSArray *features;
@property (strong, nonatomic) UIImage *image;

@property AVCaptureSession *session;

@property bool _eyes;
@property int _count;

@property bool did_sound_play;
@property bool did_sound_play_2;
@property bool is_person;
@end
