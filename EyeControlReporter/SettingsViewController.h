//
//  SettingsViewController.h
//  EyeControlReporter
//
//  Created by Hawer Torres on 22/10/12.
//  Copyright (c) 2012 Widetech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"
#import "CoreDataTableViewController.h"

@interface SettingsViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate>
{
    int accuracyGps;
    int intervaltime;
}

@property (strong, nonatomic) Settings *settings;

@property (strong, nonatomic) IBOutlet UITextField *imei;

@property (strong, nonatomic) IBOutlet UISwitch *switchAccuracylow;
@property (strong, nonatomic) IBOutlet UISwitch *switchAccuracyhigh;
@property (strong, nonatomic) IBOutlet UISwitch *switchAccuracymedia;

@property  (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic,retain) IBOutlet UISegmentedControl *segmentedControl;


-(IBAction) segmentedControlChanged;


- (IBAction)comeBack:(id)sender;

@end
