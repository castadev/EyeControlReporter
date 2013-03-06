//
//  CoreTelephony.h
//  EyeControlReporter
//
//  Created by Hawer Torres on 27/11/12.
//  Copyright (c) 2012 Widetech. All rights reserved.
//

#ifndef EyeControlReporter_CoreTelephony_h
#define EyeControlReporter_CoreTelephony_h

struct CTServerConnection
{
    int a;
    int b;
    CFMachPortRef myport;
    int c;
    int d;
    int e;
    int f;
    int g;
    int h;
    int i;
};

struct CTResult
{
    int flag;
    int a;
};

struct CTServerConnection * _CTServerConnectionCreate(CFAllocatorRef, void *, int *);

void _CTServerConnectionCopyMobileIdentity(struct CTResult *, struct CTServerConnection *, NSString **);



#endif
