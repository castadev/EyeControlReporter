//
//  CommunicationService.m
//  DemoLocation
//
//  Created by Hawer Torres on 1/10/12.
//  Copyright (c) 2012 Hawer Torres. All rights reserved.
//

#import "CommunicationService.h"

@implementation CommunicationService

@synthesize delegate;

-(void)disconnect
{
    if (readStream && writeStream)
    {
        [inputStream close];
        [outputStream close];
        readStream = nil;
        writeStream = nil;
    }
}

- (void)connect
{
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [socket performBlock:^{
        [socket enableBackgroundingOnSocket];
    }];

    [NSThread sleepForTimeInterval:20];
    
    if ([socket connectToHost:@"69.20.41.199" onPort:9008 withTimeout:5.0  error:nil])
        
    {
        
        NSLog(@"Connection performed!");
        connected = true;
        [delegate incomingMessage:self message:@"R1"];
    }
    else
    {
        connected = false;
        NSLog(@"Unable to connect: %@", nil);
    }
}


//    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"69.20.41.199", 9008, &readStream, &writeStream);
//    
// //   CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.10.83", 9008, &readStream, &writeStream);
//    
//    if (readStream && writeStream)
//    {
//        CFReadStreamSetProperty(readStream,
//                                kCFStreamPropertyShouldCloseNativeSocket,
//                                kCFBooleanTrue);
//        
//        CFWriteStreamSetProperty(writeStream,
//                                 kCFStreamPropertyShouldCloseNativeSocket,
//                                 kCFBooleanTrue);
//        
//        inputStream = (__bridge NSInputStream *)readStream;
//        
//        [inputStream setDelegate:self];
//        
//        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
//                               forMode:NSDefaultRunLoopMode];
//        [inputStream open];
//        
//        outputStream =  (__bridge  NSOutputStream *)writeStream;
//        [outputStream setDelegate:self];
//        
//        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
//                                forMode:NSDefaultRunLoopMode];
//        [outputStream open];
//        
//        
//        if(!connected)
//            [delegate incomingMessage:self message:@"R1"];
        //else
         //   [NSThread sleepForTimeInterval:10];
   // }
//}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Cool, I'm connected! That was easy.");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"SocketDidDisconnect:WithError: %@", err);
    connected = false;
    [socket disconnect];
    socket = nil;
    [self connect];
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

    NSLog(@"%@ : %@", io, event);
}

- (int)send:(NSString *)msg
{
    
    @try {
        // Try something
        NSData *dataOut = [msg dataUsingEncoding:NSUTF8StringEncoding];
        [socket  writeData:dataOut withTimeout:100 tag:1];
        if([socket isConnected])
        {
            NSLog(@"Connected");
        }else
        {
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    @finally {
        // Added to show finally works as well
    }
    
//    int result = 0;
//    @try
//    {
//       	NSData *data = [[NSData alloc] initWithData:[msg dataUsingEncoding:NSASCIIStringEncoding]];
//        result = [outputStream write:[data bytes] maxLength:[data length]];
//        return result;
//    }
//    @catch (NSException *exception) {
//        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
//    }
    
}

- (void)startService
{
    [self connect];
}

@end
