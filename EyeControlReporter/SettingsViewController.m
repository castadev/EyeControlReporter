//
//  SettingsViewController.m
//  EyeControlReporter
//
//  Created by Hawer Torres on 22/10/12.
//  Copyright (c) 2012 Widetech. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize settings;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize switchAccuracylow;
@synthesize switchAccuracyhigh;
@synthesize switchAccuracymedia;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *timeReport = [defaults objectForKey:@"timereport"];
    NSString *strImei = [defaults objectForKey:@"imei"];
    NSNumber *accuracy = [defaults objectForKey:@"accuracy"];
    
    switch ([accuracy intValue]) {
        case 1:
            [self.switchAccuracylow setOn:true];
            break;
        case 2:
            [self.switchAccuracyhigh setOn:true];
            break;
        case 3:
            [self.switchAccuracyhigh setOn:true];
            break;
            
        default:
            break;
    }
    
    switch ([timeReport intValue])
    {
		case 60:
            [self.segmentedControl setSelectedSegmentIndex:0];
			break;
		case 120:
            [self.segmentedControl setSelectedSegmentIndex:1];
            break;
        case 180:
            [self.segmentedControl setSelectedSegmentIndex:2];
			break;
        case 300:
            [self.segmentedControl setSelectedSegmentIndex:3];
			break;
        case 600:
            [self.segmentedControl setSelectedSegmentIndex:4];
			break;
        case 900:
            [self.segmentedControl setSelectedSegmentIndex:5];
			break;
        case 1200:
            [self.segmentedControl setSelectedSegmentIndex:6];
			break;
		default:
            break;
    }   
    
    self.imei.delegate = self;
    [self.imei setText:strImei];
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(IBAction) segmentedControlChanged
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
		case 0:
			intervaltime = 60;
			break;
		case 1:
			intervaltime = 120;
			break;
        case 2:
			intervaltime = 180;
			break;
        case 3:
			intervaltime = 300;
			break;
        case 4:
			intervaltime = 600;
			break;
        case 5:
			intervaltime = 900;
			break;
        case 6:
			intervaltime = 1200;
			break;
		default:
            break;
    }
}


- (IBAction)ActionChangeSwitch:(id)sender {
    UISwitch *switchObj = (UISwitch*)sender;

    if (switchObj == self.switchAccuracylow && self.switchAccuracylow.on){
        accuracyGps = 1;
        [self.switchAccuracyhigh setOn:false];
        [self.switchAccuracymedia setOn:false];
    }else if (switchObj == self.switchAccuracyhigh && self.switchAccuracyhigh.on){
        accuracyGps = 2;
        [self.switchAccuracylow setOn:false];
        [self.switchAccuracymedia setOn:false];
    }else if (switchObj == self.switchAccuracymedia && self.switchAccuracymedia.on){
        accuracyGps = 3;
        [self.switchAccuracylow setOn:false];
        [self.switchAccuracyhigh setOn:false];
    }
}

- (IBAction)comeBack:(id)sender
{
    NSNumber *timeReport = [NSNumber numberWithInt:intervaltime];
    NSString *strImei = [self.imei text];
    NSNumber *accuracy = [NSNumber numberWithInt:accuracyGps];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:timeReport forKey:@"timereport"];
    [defaults setObject:strImei forKey:@"imei"];
    [defaults setObject:accuracy forKey:@"accuracy"];

    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
