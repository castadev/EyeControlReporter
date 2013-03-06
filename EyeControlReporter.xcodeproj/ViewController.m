//
//  ViewController.m
//  EyeControlReporter
//
//  Created by Hawer Torres on 22/10/12.
//  Copyright (c) 2012 Widetech. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    float posx = (self.view.frame.size.width - 63) / 2;
    float posy = (self.view.frame.size.height - 23) / 2;
    
    RCSwitchOnOff* onSwitch = [[RCSwitchOnOff alloc] initWithFrame:CGRectMake(posx, posy, 63, 23)];
    [onSwitch setOn:YES];
    [self.view addSubview:onSwitch];
    
    onTime = false;
    oldDate = [[NSDate alloc]init];
    comServ = [[CommunicationService alloc]init];
    [comServ setDelegate:self];
    positions = [[NSMutableArray alloc]init];
    locationManager = [[CLLocationManager alloc]init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    connected = false;
    result = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)start:(SEL)selector
{
    if(!connected)
    {
        [comServ startService];
    }
}


-(void) informPosition
{
    
    double longitude = 0;
    double latitude= 0;
    int speed = 0;
    int course = 0;
    
    NSString *_date = @"20120903132733";
    
    NSString *strLat, *strLon, *strSpeed, *strCourse;
    
    ElementStatus *st =  [positions lastObject];
    
    if(st != nil )
    {
        longitude = [st longitude];
        latitude = [st latitude];
        speed = [st speed];
        course = [st course];
        _date = [st date];
    }
    
    strLat = [NSString stringWithFormat:@"%f",latitude];
    strLon = [NSString stringWithFormat:@"%f",longitude];
    strSpeed = [NSString stringWithFormat:@"%i",speed];
    strCourse = [NSString stringWithFormat:@"%i",course];
    
    @try {
        
        NSMutableString *message = [[NSMutableString alloc]init];
        [message appendString:@">R4,"];
        [message appendString:_date];
        [message appendString:@","];
        [message appendString:strLat];
        [message appendString:@","];
        [message appendString:strLon];
        [message appendString:@","];
        [message appendString:strSpeed];
        [message appendString:@","];
        [message appendString:strCourse];
        [message appendString:@"<"];
        [message appendFormat:@"\r\n"];
        
        data = [NSString stringWithString:message];
        [comServ send:data];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Error");
    }
    @finally {
        
    }
}


#pragma mark -
#pragma mark CommunicationDelegate

- (void)incomingMessage:(CommunicationService *)controller message:(NSString *) msg
{
    NSString *code = [msg substringWithRange:NSMakeRange(0, 2)];
    if([code isEqualToString:@"R1"])
    {
        double longitude = 0;
        double latitude= 0;
        int speed = 0;
        int course = 0;
        
        NSString *date = @"20120903132733";
        
        NSString *strLat, *strLon, *strSpeed, *strCourse;
        
        ElementStatus *st =  [positions lastObject];
        
        if(st != nil )
        {
            longitude = [st longitude];
            latitude = [st latitude];
            speed = [st speed];
            course = [st course];
            date = [st date];
        }
        
        strLat = [NSString stringWithFormat:@"%f",latitude];
        strLon = [NSString stringWithFormat:@"%f",longitude];
        strSpeed = [NSString stringWithFormat:@"%i",speed];
        strCourse = [NSString stringWithFormat:@"%i",course];
        
        @try {
            
            NSMutableString *message = [[NSMutableString alloc]init];
            [message appendString:@">R1,"];
            [message appendString:date];
            [message appendString:@","];
            [message appendString:strLat];
            [message appendString:@","];
            [message appendString:strLon];
            [message appendString:@","];
            [message appendString:strSpeed];
            [message appendString:@","];
            [message appendString:strCourse];
            [message appendFormat:@";"];
            [message appendFormat:@"013051005386477"];
            [message appendString:@"<"];
            [message appendFormat:@"\r\n"];
            
            NSString *msg = [NSString stringWithString:message];
            result = [comServ send:msg];
        }
        @catch (NSException *exception) {
            NSLog(@"Error");
        }
        @finally {
        }
    }
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    int count = [locations count];
    
    NSDate *currentDate = [[NSDate alloc]init];
    NSTimeInterval interval = [currentDate timeIntervalSinceDate:oldDate];
    if(count > 0)
    {
        paused = false;
        CLLocation *lastLocation = [locations objectAtIndex:(count - 1)];
        NSTimeInterval locationAge = -[lastLocation.timestamp timeIntervalSinceNow];
        time = time + locationAge;
        if(locationAge > 10.0) return;
        if(lastLocation.horizontalAccuracy < 0) return;
        
        intervalTime = locationAge + intervalTime;
        
        CLLocationCoordinate2D currentCoordinates = lastLocation.coordinate;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"yyyy"];
        NSMutableString *year = [NSMutableString stringWithFormat:@"%i",[[dateFormatter stringFromDate:[NSDate date]] intValue]];
        
        [dateFormatter setDateFormat:@"MM"];
        NSMutableString *month = [NSMutableString stringWithFormat:@"%i",[[dateFormatter stringFromDate:[NSDate date]] intValue]];
        
        if([month length] < 2)
        {
            NSRange range = NSMakeRange(0, 1);
            [month replaceCharactersInRange:range withString:@"0"];
            [month appendFormat:@"%i",[[dateFormatter stringFromDate:[NSDate date]] intValue]];
        }
        
        [dateFormatter setDateFormat:@"dd"];
        NSMutableString *day = [NSMutableString stringWithFormat:@"%i",[[dateFormatter stringFromDate:[NSDate date]] intValue]];
        if([day length] < 2)
        {
            NSRange range = NSMakeRange(0, 1);
            [day replaceCharactersInRange:range withString:@"0"];
            [day appendFormat:@"%i",[[dateFormatter stringFromDate:[NSDate date]] intValue]];
        }
        
        [dateFormatter setDateFormat:@"HH"];
        NSMutableString *hour = [NSMutableString stringWithFormat:@"%i",[[dateFormatter stringFromDate:[NSDate date]] intValue]];
        if([hour length] < 2)
        {
            
            NSRange range = NSMakeRange(0, 1);
            [hour replaceCharactersInRange:range withString:@"0"];
            [hour appendFormat:@"%i",[[dateFormatter stringFromDate:[NSDate date]] intValue]];
        }
        
        [dateFormatter setDateFormat:@"mm"];
        NSMutableString *minute = [NSMutableString stringWithFormat:@"%i",[[dateFormatter stringFromDate:[NSDate date]] intValue]];
        if([minute length] < 2)
        {
            NSRange range = NSMakeRange(0, 1);
            [minute replaceCharactersInRange:range withString:@"0"];
            [minute appendFormat:@"%i",[[dateFormatter stringFromDate:[NSDate date]] intValue]];
        }
        
        [dateFormatter setDateFormat:@"ss"];
        NSMutableString *second = [NSMutableString stringWithFormat:@"%i",[[dateFormatter stringFromDate:[NSDate date]] intValue]];
        
        if([second length] < 2)
        {
            NSRange range = NSMakeRange(0, 1);
            [second replaceCharactersInRange:range withString:@"0"];
            [second appendFormat:@"%i",[[dateFormatter stringFromDate:[NSDate date]] intValue]];
        }
        
        NSString *date = [NSString stringWithFormat:@"%@%@%@%@%@%@",year,month,day,hour,minute,second];
        elementStatus = [[ElementStatus alloc]init];
        [elementStatus setLatitude:currentCoordinates.latitude];
        [elementStatus setLongitude:currentCoordinates.longitude];
        [elementStatus setCourse:lastLocation.course];
        [elementStatus setSpeed:lastLocation.speed];
        [elementStatus setDate:date];
        [positions addObject:elementStatus];
        
        if(interval >= 60.0)
        {
            oldDate = [[NSDate alloc]init];
            [self informPosition];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    NSLog(@"Unable to start location manager. Error:%@", [error description]);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Unable to start location manager. Error:%@", [error description]);
}

-(void) updatePosition:(NSTimer *) theTimer
{
    NSLog(@"Is Pause %@\n", (paused ? @"YES" : @"NO"));
    paused = true;
    if(paused){
        double longitude = 0;
        double latitude= 0;
        int speed = 0;
        int course = 0;
        
        NSString *_date = @"20120903132733";
        
        NSString *strLat, *strLon, *strSpeed, *strCourse;
        
        ElementStatus *st =  [positions lastObject];
        
        if(st != nil )
        {
            longitude = [st longitude];
            latitude = [st latitude];
            speed = [st speed];
            course = [st course];
            _date = [st date];
        }
        
        strLat = [NSString stringWithFormat:@"%f",latitude];
        strLon = [NSString stringWithFormat:@"%f",longitude];
        strSpeed = [NSString stringWithFormat:@"%i",speed];
        strCourse = [NSString stringWithFormat:@"%i",course];
        
        @try {
            
            NSMutableString *message = [[NSMutableString alloc]init];
            
            [message appendString:@">R4,"];
            [message appendString:_date];
            [message appendString:@","];
            [message appendString:strLat];
            [message appendString:@","];
            [message appendString:strLon];
            [message appendString:@","];
            [message appendString:strSpeed];
            [message appendString:@","];
            [message appendString:strCourse];
            [message appendString:@"<"];
            [message appendFormat:@"\r\n"];
            
            data = [NSString stringWithString:message];
            [comServ send:data];
            NSLog(@"%@",data);
            
        }
        @catch (NSException *exception) {
            NSLog(@"Error");
        }
        @finally {
            
        }
    }
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    //reset location service
    oldDate = [[NSDate alloc]init];
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        //Check if our iOS version supports multitasking I.E iOS 4
		if ([[UIDevice currentDevice] isMultitaskingSupported]) { //Check if device supports mulitasking
			UIApplication *application = [UIApplication sharedApplication]; //Get the shared application instance
            
			__block UIBackgroundTaskIdentifier background_task; //Create a task object
            
			background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
				[application endBackgroundTask: background_task]; //Tell the system that we are done with the tasks
				background_task = UIBackgroundTaskInvalid; //Set the task to be invalid
			}];
            
			//Background tasks require you to use asyncrous tasks
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				//Perform your tasks that your application requires
                
                //    locationManager.distanceFilter = 20;
                
                //  [NSThread detachNewThreadSelector:@selector(informPosition:) toTarget:self withObject:nil];
                
                [locationManager stopUpdatingLocation];
                
                [locationManager startUpdatingLocation];
				[application endBackgroundTask: background_task]; //End the task so the system knows that you are done with what you need to perform
				background_task = UIBackgroundTaskInvalid; //Invalidate the background_task
			});
		}
	}
}


- (IBAction)startTrack:(id)sender
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        //Check if our iOS version supports multitasking I.E iOS 4
		if ([[UIDevice currentDevice] isMultitaskingSupported]) { //Check if device supports mulitasking
			UIApplication *application = [UIApplication sharedApplication]; //Get the shared application instance
            
			__block UIBackgroundTaskIdentifier background_task; //Create a task object
            
			background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
				[application endBackgroundTask: background_task]; //Tell the system that we are done with the tasks
				background_task = UIBackgroundTaskInvalid; //Set the task to be invalid
			}];
            
			//Background tasks require you to use asyncrous tasks
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				//Perform your tasks that your application requires
                
                //    locationManager.distanceFilter = 20;
                
                //  [NSThread detachNewThreadSelector:@selector(informPosition:) toTarget:self withObject:nil];
                
                [locationManager stopUpdatingLocation];
                
                [locationManager startUpdatingLocation];
				[application endBackgroundTask: background_task]; //End the task so the system knows that you are done with what you need to perform
				background_task = UIBackgroundTaskInvalid; //Invalidate the background_task
			});
		}
	}
    [NSThread detachNewThreadSelector:@selector(start:) toTarget:self withObject:nil];
}

@end
