//
//  CommunicationService.m
//  DemoLocation
//
//  Created by Hawer Torres on 1/10/12.
//  Copyright (c) 2012 Hawer Torres. All rights reserved.
//

#import "CommunicationService.h"

@implementation CommunicationService

@synthesize delegate,logDelegate;

-(void)disconnect
{
        [socket disconnectAfterReadingAndWriting];
       // socket = nil;
}

- (void)connect
{
    
    [logDelegate logMessage:self message:@"try to connect"];
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [socket performBlock:^{
        [socket enableBackgroundingOnSocket];
    }];
    
    if ([socket connectToHost:@"69.20.41.199" onPort:9008 withTimeout:5.0  error:nil])
  //       if ([socket connectToHost:@"192.168.10.83" onPort:9008 withTimeout:5.0  error:nil])
    {
        [logDelegate logMessage:self message:@"Connection performed"];
        connected = true;
        [delegate incomingMessage:self message:@"R1"];
    }
    else
    {
        [logDelegate logMessage:self message:@"Unable to connect"];
        connected = false;
    }
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    [logDelegate logMessage:self message:@"Cool, I'm connected!"];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [logDelegate logMessage:self message:@"SocketDidDisconnect:WithError"];
    connected = false;
    [socket disconnectAfterReadingAndWriting];
}

-(void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    NSString *io;
    if (theStream == inputStream) io = @">>";
    else io = @"<<";

    NSString *event;
    
    switch (streamEvent)
    {
        case NSStreamEventNone:
            event = @"NSStreamEventNone";
            break;

        case NSStreamEventOpenCompleted:
            event = @"NSStreamEventOpenCompleted";
            connected = true;
            break;

        case NSStreamEventHasBytesAvailable:
            event = @"NSStreamEventHasBytesAvailable";
            break;

        case NSStreamEventHasSpaceAvailable:
            event = @"NSStreamEventHasSpaceAvailable";
            break;

        case NSStreamEventErrorOccurred:
        {
            event = @"NSStreamEventErrorOccurred";   
            connected = false;           
            break;
        }

        case NSStreamEventEndEncountered:
            event = @"NSStreamEventEndEncountered";
            break;

        default:
            event = @"** Unknown";
    }
    
    [logDelegate logMessage:self message:event];

    NSLog(@"%@ : %@", io, event);
}

- (int)send:(NSString *)msg
{   
    @try {
        NSData *dataOut = [msg dataUsingEncoding:NSUTF8StringEncoding];
        [socket  writeData:dataOut withTimeout:100 tag:1];
    }
    @catch (NSException * e) {
        [logDelegate logMessage:self message:@"Error send message"];
    }
    @finally {
        // Added to show finally works as well
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)startService
{
    [self connect];
}

@end
