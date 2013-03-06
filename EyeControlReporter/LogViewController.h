//
//  LogViewController.h
//  EyeControlReporter
//
//  Created by Hawer Torres on 15/11/12.
//  Copyright (c) 2012 Widetech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogViewController : UITableViewController
{
    UILabel* logLabel;
}

@property (nonatomic,strong) NSMutableArray *log;
@property (nonatomic,strong) UILabel *logLabel;

- (IBAction)comeBack:(id)sender;
- (IBAction)clearLog:(id)sender;

@end
