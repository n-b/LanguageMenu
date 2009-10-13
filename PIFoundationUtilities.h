//
//  PIFoundationUtilities.h
//
//  Created by Nicolas Bouilleaud on 31/01/07.
// 
// +----------------------------------------------------------------------------------------+
// | Utility functions for low-level tasks.													|
// | Implemented using good ol'libc.														|
// +----------------------------------------------------------------------------------------+

#import <Foundation/Foundation.h>


#ifdef __cplusplus
extern "C" {
#endif


/*!
	@function LCRunningProcesses
	@abstract Get an array of all the running processes on the machine
	@discussion each entry of the array is a dictionary containing the following keys:
	- @"name" : the process name
	- @"pid" : the process pid
	Code could be modified to include other values of interest.
	@result the array of process dictionaries, autoreleased
 */
NSArray * LCRunningProcesses();

/*!
	@function LCProcessIsRunning
	@abstract Look if a process is running
	@param processName the name of the process to look at.
	@discussion Look if a process is running
	@result YES if the process named processName is currently running.
 */
BOOL LCProcessIsRunning(NSString * processName);

/*!
	@function LCCreateLoginItemsArray
	@abstract return the login items list of the current user or for any user.
	@param userType the type of the user domain : kCFPreferencesCurrentUser or kCFPreferencesAnyUser
	@return the login items list.
 */
NSArray * LCLoginItems(CFStringRef userType);

/*!
	@function LCItemIsOpenedAtLogin:
	@abstract return whether an item is in the loginitems list
	@discussion the current implementation uses LoginItemsAE
	@param itemPath the full path to the item
	@param userType the type of the user domain : kCFPreferencesCurrentUser or kCFPreferencesAnyUser
	@return true if the item is in the login items list.
 */
BOOL LCItemIsOpenedAtLogin(NSString * itemPath, CFStringRef userType);

/*!
	@function LCOpenItemAtLogin:
	@abstract add an item to the loginitems list.
	@discussion the current implementation uses LoginItemsAE
	@param itemPath the full path to the item to open at login.
	@param openItem wether to add or to remove it from the list.
	@param hideItem wether to hide the item when opened at login.
	@param userType the type of the user domain : kCFPreferencesCurrentUser or kCFPreferencesAnyUser
	@return true if the item is in the loginitems list.
 */
void LCSetItemIsOpenedAtLogin(NSString * itemPath, BOOL openItem, BOOL hideItem, CFStringRef userType);

/*!
	@function LCLocalFirewallIsActive:
	@abstract Returns YES if the local firewall is active.
	@discussion If the status can't be determined, returns NO
 */
BOOL LCLocalFirewallIsActive();

/*!
	@function LCLocalFirewallBlocksPort:
	@abstract Returns YES if the local firewall is set to block the passed port
	@param port the port number
	@param protocol the transport protocol. should be either "udp" or "tcp"
	@discussion If the status can't be determined, returns NO. 
	This methods only makes sense in systems from 10.2 to 10.4.
 */
BOOL LCLocalFirewallBlocksPort(unsigned short port, const char* protocol);

/*!
	@function LCLocalFirewallBlocksApplication:
	@abstract Returns YES if the local firewall is set to block the application based on its bundleID
	@param port the bundleID
	@discussion If the status can't be determined, returns NO. 
	This methods only makes sense in systems from 10.5
*/
BOOL LCLocalFirewallBlocksApplication(NSString* bundleID);

/*!
	@function LCQuitApplication:
	@abstract Quit an application identified by its name.
	@parameter applicationName : the name of the application (without the ".app" suffix) to quit.
	@parameter errorInfo : a dictionary containing info about the error (if there is one).
	@discussion Quit an application identified by its name.
	@result NSAppleEventDescriptor : The result of executing the event, or nil if an error occurs.
*/
NSAppleEventDescriptor * LCQuitApplication(	NSString *		applicationName,
										   NSDictionary **	errorInfo);

/*!
	@function LCProcessNameFromPID:
	@abstract Get the process name given a PID
	@param aPID the PID...
	@result the process name, autoreleased, or nil on failure
*/
NSString * LCProcessNameFromPID( pid_t pid );
	
#ifdef __cplusplus
}
#endif