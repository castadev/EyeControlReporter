//
//  Settings.h
//  EyeControlReporter
//
//  Created by Hawer Torres on 23/10/12.
//  Copyright (c) 2012 Widetech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Settings : NSManagedObject

@property (nonatomic, retain) NSString * imei;
@property (nonatomic, retain) NSString * kindgps;
@property (nonatomic, retain) NSNumber * interval;
@property (nonatomic, retain) NSString * deviceid;

@end
