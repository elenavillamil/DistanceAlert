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
    
    self._eyes = false;
    self._count = 0;
    
    [self setupCaptureSession];
    
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

// Create and configure a capture session and start it running
- (void)setupCaptureSession
{
    NSError *error = nil;
    
    // Create the session
    self.session = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = nil;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *d in devices) {
        if ([d position] == AVCaptureDevicePositionFront) {
            device = d;
        }
    }
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input) {
        NSLog(@"Couldn't connect to the front camera");
        return;
    }
    
    [self.session addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [self.session addOutput:output];
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    //dispatch_release(queue);
    
    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    
    // If you wish to cap the frame rate to a known value, such as 15 fps, set
    // minFrameDuration.
    //output.minFrameDuration = CMTimeMake(1, 15);
    
    // Start the session running to start the flow of data
    [self.session startRunning];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data
    self.image = [self imageFromSampleBuffer:sampleBuffer];
    
    int orientation = self.image.imageOrientation;
    
    UIDeviceOrientation device_orientation = [UIDevice currentDevice].orientation;
    
    if (device_orientation == UIDeviceOrientationPortrait)
    {
        self.image = [UIImage imageWithCGImage:self.image.CGImage scale:self.image.scale orientation:UIImageOrientationRight];
    }
    
    else if (device_orientation == UIDeviceOrientationLandscapeLeft)
    {
        self.image = [UIImage imageWithCGImage:self.image.CGImage scale:self.image.scale orientation:UIImageOrientationDown];
    }
    
    switch (self.image.imageOrientation) {
        case UIImageOrientationUp:
            orientation = 1;
            
            break;
        case UIImageOrientationDown:
            orientation = 3;
            
            break;
        case UIImageOrientationLeft:
            orientation = 8;
            break;
        case UIImageOrientationRight:
            orientation = 6;
            break;
        case UIImageOrientationUpMirrored:
            orientation = 2;
            break;
        case UIImageOrientationDownMirrored:
            orientation = 4;
            break;
        case UIImageOrientationLeftMirrored:
            orientation = 5;
            break;
        case UIImageOrientationRightMirrored:
            orientation = 7;
            break;
        default:
            break;
    }

    
    if (self.detectorOptions == nil)
    {
        self.detectorOptions = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
        self.face_detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:self.detectorOptions];
    }
    
    self.features = [self.face_detector featuresInImage:[CIImage imageWithCGImage:self.image.CGImage] options:@{ CIDetectorEyeBlink : @YES,
                                                                                                                 CIDetectorImageOrientation :[NSNumber numberWithInt:orientation] }];
    
    for (CIFaceFeature *f in self.features)
    {
        if (f.leftEyeClosed && f.rightEyeClosed)
        {
            self._eyes = true;
            self._count++;
            
            if (self._count > 2)
                NSLog(@"Eyes are closed");
        }
        
        else
        {
            self._eyes = false;
            self._count = 0;
            NSLog(@"Eyes are open");
        }
    }
    
    /*dispatch_async(dispatch_get_main_queue(), ^{
     [self.image_view setImage:self.image];
     
     }); */
    
    //< Add your code here that uses the image >
    
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

@end
