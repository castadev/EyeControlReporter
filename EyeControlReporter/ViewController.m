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

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize locationManager;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    float posx = (self.view.frame.size.width - 127) / 2;
    float posy = (self.view.frame.size.height - 44) / 2;
    
    onSwitch = [[RCSwitchOnOff alloc] initWithFrame:CGRectMake(posx, posy, 127, 44)];
    [onSwitch addTarget:self action:@selector(didChange:) forControlEvents:UIControlEventValueChanged];
    [onSwitch setOn:NO];
    [self.view addSubview:onSwitch];
    
    onTime = false;
    oldDate = [[NSDate alloc]init];
    comServ = [[CommunicationService alloc]init];
    [comServ setDelegate:self];
    [comServ setLogDelegate:self];
    positions = [[NSMutableArray alloc]init];
    locationManager = [[CLLocationManager alloc]init];
    [locationManager setDelegate:self];
    
    connected = false;
    result = -1;    
    log = [[NSMutableArray alloc] init];
}

-(void)viewDidAppear:(BOOL)animated
{
    defaults = [NSUserDefaults standardUserDefaults];
    
    timeReport = [[defaults objectForKey:@"timereport"] integerValue];
    imei = [defaults objectForKey:@"imei"];
    
    if(timeReport == 0)
    {
        timeReport = 60;
    }
    if(imei == nil)
    {
        [self performSegueWithIdentifier:@"pushSettingsView" sender:self];
    }

    [self desiredAccuracy:[[defaults objectForKey:@"accuracy"]intValue]];
}


-(void)desiredAccuracy:(NSInteger)number
{
    switch (number) {

        case 1:
            [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
            break;
        case 2:
            [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
            break;
        case 3:
            [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showAlert:(NSString *)text {
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                        message:text delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
	[alertView show];
}

- (void) didChange:(id)sender {
    if (onSwitch.on)
    {
        //get imei
        imei = [defaults objectForKey:@"imei"];
        if(!(imei == nil))
        {
            [self startServices];
        }else
        {
            [onSwitch setOn:NO];
        }
    }
    else
    {
        [comServ disconnect];
        [locationManager stopUpdatingLocation];
        oldDate = [[NSDate alloc]init];
    }
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
        [log addObject:@"Error informPosition"];
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
        //get imei
        imei =  [defaults objectForKey:@"imei"];
        
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
            [message appendString:@";"];
            [message appendString:imei];
            [message appendString:@"<"];
            [message appendFormat:@"\r\n"];
            
            NSString *msg = [NSString stringWithString:message];
            result = [comServ send:msg];
        }
        @catch (NSException *exception) {
           [log addObject:@"Error report R1"];
        }
        @finally {
            
        }
    }
}

#pragma mark - CommunicationLogDelegate

-(void)logMessage:(CommunicationService *)controller message:(NSString *)msg
{
    [log addObject:msg];
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
        
        timeReport = [[defaults objectForKey:@"timereport"] integerValue];
        
        if(timeReport == 0)
        {
            timeReport = 60;
        }
        
        if(interval >= timeReport)
        {
            [log addObject:@"Reporting R4"];
            oldDate = [[NSDate alloc]init];
            [self informPosition];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    [log addObject:@"didFinishDeferredUpdatesWithError"];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [log addObject:@"didFailWithError"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if([segue.identifier isEqualToString:@"viewLog"])
   {
       UINavigationController *navController = segue.destinationViewController;
       LogViewController *logView = [[navController viewControllers] objectAtIndex:0];
       [logView setLog:log];
   }
}


- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    
    [log addObject:@"locationManagerDidPauseLocationUpdates"];
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

- (void)startServices
{
    [locationManager stopUpdatingLocation];
    [locationManager startUpdatingLocation];
    [NSThread detachNewThreadSelector:@selector(start:) toTarget:self withObject:nil];
}

- (void)startTrack
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
                [locationManager stopUpdatingLocation];
                
                [locationManager startUpdatingLocation];
				[application endBackgroundTask: background_task]; //End the task so the system knows that you are done with what you need to perform
				background_task = UIBackgroundTaskInvalid; //Invalidate the background_task
			});
		}
	}
    [NSThread detachNewThreadSelector:@selector(start:) toTarget:self withObject:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

