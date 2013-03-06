//
//  main.m
//  EyeControlReporter
//
//  Created by Hawer Torres on 22/10/12.
//  Copyright (c) 2012 Widetech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        
        
        @try {
            // Try something
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
        @finally {
            // Added to show finally works as well
        }

    }
}
