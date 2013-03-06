//
//  ViewController.h
//  EyeControlReporter
//
//  Created by Hawer Torres on 22/10/12.
//  Copyright (c) 2012 Widetech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CommunicationService.h"
#import "ElementStatus.h"
#import "RCSwitchOnOff.h"


@interface ViewController : UIViewController <CLLocationManagerDelegate, CommunicationDelegate>
{
    NSMutableArray *positions;
    int result;
    CommunicationService *comServ;
    CLLocationManager *locationManager;
    ElementStatus *elementStatus;
    NSTimeInterval intervalTime;
    NSTimer *stopWatchTimer;
    NSString *data;
    bool service;
    bool onTime;
    bool connected;
    bool paused;
    NSTimeInterval time;
    NSDate *oldDate;
}

@property(nonatomic, strong) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UISwitch *serviceSwitch;



- (IBAction)startTrack:(id)sender;

@end
