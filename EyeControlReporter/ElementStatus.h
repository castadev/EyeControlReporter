//
//  ElementStatus.h
//  DemoLocation
//
//  Created by Hawer Torres on 1/10/12.
//  Copyright (c) 2012 Hawer Torres. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ElementStatus : NSObject
{
    double latitude;
    double longitude;
    int speed;
    int course;
    NSString *date;
}

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) int speed;
@property (nonatomic, assign) int course;
@property (nonatomic, strong) NSString *date;

@end
