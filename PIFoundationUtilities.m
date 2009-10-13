//
//  PIFoundationUtilities.m
//
//  Created by Nicolas Bouilleaud on 31/01/07.
//
// +----------------------------------------------------------------------------------------+
// | Utility functions for low-level tasks.													|
// | Implemented using good ol'libc and [NS|Core]Foundation									|
// +----------------------------------------------------------------------------------------+

#import "PIFoundationUtilities.h"
#include <SystemConfiguration/SystemConfiguration.h>
#import <objc/objc-class.h>

//For GetBSDProcessList:
#include <assert.h>
#include <errno.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/sysctl.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <netdb.h>
#include <net/if.h>


// +------------------------------------------------------------------------+
// Below is Apple code from: http://developer.apple.com/qa/qa2001/qa1123.html

typedef struct kinfo_proc kinfo_proc;

static int GetBSDProcessList(kinfo_proc **procList, size_t *procCount)
// Returns a list of all BSD processes on the system.  This routine
// allocates the list and puts it in *procList and a count of the
// number of entries in *procCount.  You are responsible for freeing
// this list (use "free" from System framework).
// On success, the function returns 0.
// On error, the function returns a BSD errno value.
{
    int             err;
    kinfo_proc *    result;
    bool			done;
	int				name[] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    size_t          length;
	
    assert( procList != NULL);
    assert(*procList == NULL);
    assert(procCount != NULL);
	
    *procCount = 0;
	
    // We start by calling sysctl with result == NULL and length == 0.
    // That will succeed, and set length to the appropriate length.
    // We then allocate a buffer of that size and call sysctl again
    // with that buffer.  If that succeeds, we're done.  If that fails
    // with ENOMEM, we have to throw away our buffer and loop.  Note
    // that the loop causes use to call sysctl with NULL again; this
    // is necessary because the ENOMEM failure case sets length to
    // the amount of data returned, not the amount of data that
    // could have been returned.
	
    result = NULL;
    done = false;
    do {
        assert(result == NULL);
		
        // Call sysctl with a NULL buffer.
		
        length = 0;
        err = sysctl( (int *) name, (sizeof(name) / sizeof(*name)) - 1,
                      NULL, &length,
                      NULL, 0);
        if (err == -1) {
            err = errno;
        }
		
        // Allocate an appropriately sized buffer based on the results
        // from the previous call.
		
        if (err == 0) {
            result = malloc(length);
            if (result == NULL) {
                err = ENOMEM;
            }
        }
		
        // Call sysctl again with the new buffer.  If we get an ENOMEM
        // error, toss away our buffer and start again.
		
        if (err == 0) {
            err = sysctl( (int *) name, (sizeof(name) / sizeof(*name)) - 1,
                          result, &length,
                          NULL, 0);
            if (err == -1) {
                err = errno;
            }
            if (err == 0) {
                done = true;
            } else if (err == ENOMEM) {
                assert(result != NULL);
                free(result);
                result = NULL;
                err = 0;
            }
        }
    } while (err == 0 && ! done);
	
    // Clean up and establish post conditions.
	
    if (err != 0 && result != NULL) {
        free(result);
        result = NULL;
    }
    *procList = result;
    if (err == 0) {
        *procCount = length / sizeof(kinfo_proc);
    }
	
    assert( (err == 0) == (*procList != NULL) );
	
    return err;
}


NSArray * LCRunningProcesses()
{
	int err;
	kinfo_proc *procList = NULL;
	size_t procCount;
	int i;

	err = GetBSDProcessList(&procList,&procCount);
	if(err != 0){
		if(procList != NULL)
			free(procList);
		return nil;
	}
	
	// I have my list of processes. Build a dictionary...
	NSMutableArray * processes = [NSMutableArray arrayWithCapacity:procCount];
	for(i = 0;i<procCount;i++)
	{
		// for now we only set the name property.
		[processes addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:procList[i].kp_proc.p_pid],@"pid",
							  [NSString stringWithCString:procList[i].kp_proc.p_comm encoding:NSASCIIStringEncoding],@"name",
			nil]];
	}
	
	free(procList);
	return processes;
}

NSString * LCProcessNameFromPID( pid_t pid )
{
	OSErr				err;
	NSString *			processName;
    ProcessSerialNumber psn;
	psn.highLongOfPSN = 0;
	psn.lowLongOfPSN = 0;
	
    err = GetProcessForPID(pid, &psn);
    if (err == noErr)
    {
		//Get name as CFString, which is bridged to NSString
		CopyProcessName(&psn, (CFStringRef*)&processName);
		return [processName autorelease];
	}
	return nil;
}
