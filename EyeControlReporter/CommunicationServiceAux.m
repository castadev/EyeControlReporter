//
//  CommunicationServiceAux.m
//  EyeControlReporter
//
//  Created by Hawer Torres on 26/11/12.
//  Copyright (c) 2012 Widetech. All rights reserved.
//

#import "CommunicationServiceAux.h"

@implementation CommunicationServiceAux


- (void) connect
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, @"", 80, &readStream, &writeStream);
}


- (void) startService
{
    //just try connect
    [self connect];
}

@end
