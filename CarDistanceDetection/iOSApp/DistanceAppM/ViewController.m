//
//  ViewController.m
//  DistanceAppM
//
//  Created by Cheong on 15/8/12.
//  Modified by Eric Larson, 2014
//  Modified by Maria Elena Villamil, 2014
//  Copyright (c) 2014 Maria Elena Villamil. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.DistanceLabel.text = @"Connecting Please Wait...";
    self.PersonLabel.text = @" ";
    self.did_sound_play = false;
    self.is_person = false;
    
    m_ble_endpoint = [[BLE alloc] init];
    [m_ble_endpoint controlSetup];
    
    // Set up the delegate to be this class
    m_ble_endpoint.delegate = self;
    
    [self performSelectorInBackground:@selector(bleConnect:) withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) bleDidConnect
{
    self.DistanceLabel.text = @"";
}

-(void) bleDidDisconnect
{
    self.DistanceLabel.text = @"Disconnected.";
    
    // Functionality to reconnect
    [self bleConnect:nil];
}

// Receiving the Data
- (void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSData* input_data = [NSData dataWithBytes:data length:length];
    NSString* parsed_str = [[NSString alloc] initWithData:input_data encoding:NSUTF8StringEncoding];

    NSLog(@"%@", parsed_str);
    
    NSString* replacement= @" ";
    NSRange range_to_replace = {parsed_str.length - 1, 1};
    
    if ([parsed_str characterAtIndex:parsed_str.length - 1] == 'P')
    {
        NSLog(@"Person recognized");
        self.is_person = true;
        parsed_str = [parsed_str stringByReplacingCharactersInRange:range_to_replace withString: replacement];
    }
    else if ([parsed_str characterAtIndex:parsed_str.length -1] == 'N')
    {
        NSLog(@"No Person");
        self.is_person = false;
        parsed_str = [parsed_str stringByReplacingCharactersInRange:range_to_replace withString: replacement];

    }
    
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* distance = [formatter numberFromString:parsed_str];
    
    if (distance.intValue <= 500 && self.is_person)
    {
        self.view.backgroundColor = [UIColor redColor];

        self.PersonLabel.text = @"Careful. There is a person!!";
        self.DistanceLabel.text = parsed_str;
        self.DistanceLabel.font = [UIFont systemFontOfSize:80];
        if(!self.did_sound_play)
        {
            self.did_sound_play = true;
            SystemSoundID sound_id;
            NSString* alarm_sound_file = [[NSBundle mainBundle] pathForResource:@"Alarm Sound" ofType:@"mp3"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:alarm_sound_file], &sound_id);
            AudioServicesPlaySystemSound(sound_id);
        }
    }
    
    else if (distance.intValue <= 100)
    {
        self.view.backgroundColor = [UIColor redColor];
        
        self.DistanceLabel.font = [UIFont systemFontOfSize:80];
        self.DistanceLabel.text = parsed_str;
        self.PersonLabel.text = @"";
        
        self.did_sound_play = false;
    }
    
    else
    {
        self.view.backgroundColor = [UIColor greenColor];
        
        self.DistanceLabel.font = [UIFont systemFontOfSize:20];
        self.DistanceLabel.text = @"";
        self.PersonLabel.text = @"";
        
        self.did_sound_play = false;
    }
    
}

- (void) bleConnect:(id) param
{
    self.DistanceLabel.text = @"Connecting Please Wait...";

    [NSThread sleepForTimeInterval:.5f];
    
    //start search for peripherals with a timeout of 3 seconds
    // this is an asunchronous call and will return before search is complete
    [m_ble_endpoint findBLEPeripherals:3];
    
    // Sleep the three seconds
    [NSThread sleepForTimeInterval:3.0f];
    
    if(m_ble_endpoint.peripherals.count > 0)
    {
        // connect to the first found peripheral
        
        for(int i = 0; i < m_ble_endpoint.peripherals.count; ++i)
        {
            CBPeripheral* peripheral = [m_ble_endpoint.peripherals objectAtIndex:i];
            
            if ([peripheral.name isEqualToString:@"ev9"])
            {
                [m_ble_endpoint connectPeripheral:[m_ble_endpoint.peripherals objectAtIndex:i]];
            }
        }
        
    }
}

- (IBAction)Connect:(id)sender {
}
@end
