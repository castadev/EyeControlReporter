//
//  CommunicationService.h
//  DemoLocation
//
//  Created by Hawer Torres on 1/10/12.
//  Copyright (c) 2012 Hawer Torres. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@class CommunicationService;


@protocol CommunicationDelegate
- (void)incomingMessage:(CommunicationService *)controller message:(NSString *) msg;
@end

@interface CommunicationService : NSObject <NSStreamDelegate>
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString *stringFromData;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    bool connected;
    GCDAsyncSocket *socket;
}

@property (nonatomic, strong) id <CommunicationDelegate> delegate;

- (void)startService;
- (int)send:(NSString *)msg;
- (void)disconnect;

@end
