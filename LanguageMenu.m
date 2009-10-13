//
//  LanguageMenu.m
//  LanguageMenu
//
//  Created by Nicolas Bouilleaud on 23/01/08.
//

#import "LanguageMenu.h"
#import "PIFoundationUtilities.h"

@implementation LanguageMenu

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		appsToRelaunch = [[NSMutableArray alloc] initWithCapacity:10];
		
		statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:20] retain];
		[statusItem setLength:NSVariableStatusItemLength];
		[statusItem setHighlightMode:YES];

		langmenu = [[NSMenu alloc] init];
		[langmenu setDelegate:self];
		[statusItem setMenu:langmenu];
		[self menuNeedsUpdate:langmenu];

		appsmenu = [[NSMenu alloc] init];
		[appsmenu setDelegate:self];
		
	}
	return self;
}

- (NSArray*) languages
{
	CFPropertyListRef propertyListRef = CFPreferencesCopyValue(CFSTR("AppleLanguages"), kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if( propertyListRef != NULL && CFGetTypeID(propertyListRef) == CFArrayGetTypeID() )
		return [(NSArray*)propertyListRef autorelease];
	else
		CFRelease(propertyListRef);
	
	return nil;
}


- (BOOL) setLanguages:(NSArray*) newLanguages
{
	CFPreferencesSetValue(CFSTR("AppleLanguages"), (CFPropertyListRef)newLanguages, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	return CFPreferencesSynchronize(kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

- (void)menuNeedsUpdate:(NSMenu *)amenu
{
	if(amenu==langmenu)
	{
		NSArray * languages = [self languages];
		if( [languages count] != 0 )
		{
			[statusItem setTitle:[languages objectAtIndex:0]];
			
			while( [langmenu numberOfItems] != 0 )
				[langmenu removeItemAtIndex:0];
			
			NSLocale * currentLocale = [[[NSLocale alloc] initWithLocaleIdentifier:[languages objectAtIndex:0]] autorelease];
			NSString * language;
			NSEnumerator * langEnum = [languages objectEnumerator];
			
			while( (language=[langEnum nextObject])!=nil )
			{
				NSMenuItem * menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%@)",
																		   [currentLocale displayNameForKey:NSLocaleIdentifier value:language], 
																		   language] 
																   action:@selector(selectLanguage:) 
															keyEquivalent:@""]; 
				[menuItem setRepresentedObject:language];
				[menuItem setTarget:self];
				[langmenu addItem:menuItem];
				[menuItem release];
			}
			
			[langmenu addItem:[NSMenuItem separatorItem]];
			NSMenuItem * relaunchMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Auto relaunch (%d)",[appsToRelaunch count]]
																	   action:@selector(terminate:)
																keyEquivalent:@""]; 
			[relaunchMenuItem setSubmenu:appsmenu];
			[langmenu addItem:relaunchMenuItem];
			
			[langmenu addItem:[NSMenuItem separatorItem]];
			NSMenuItem * quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""]; 
			[quitMenuItem setTarget:NSApp];
			[langmenu addItem:quitMenuItem];
			[quitMenuItem release];
		}
	}
	else if(amenu==appsmenu)
	{
		while( [appsmenu numberOfItems] != 0 )
			[appsmenu removeItemAtIndex:0];

		NSArray * apps = LCRunningProcesses();
		NSDictionary * app;
		NSEnumerator * appEnum = [apps objectEnumerator];
		while( (app=[appEnum nextObject])!=nil ) {
			pid_t pid = [[app objectForKey:@"pid"] intValue];
			NSString * name = LCProcessNameFromPID(pid);
			if( nil!=name )
			{
				NSMenuItem * menuItem = [[NSMenuItem alloc] initWithTitle:name action:@selector(setRelaunchApp:) keyEquivalent:@""]; 
				[menuItem setRepresentedObject:name];
				[menuItem setTarget:self];
				if([appsToRelaunch containsObject:[menuItem representedObject]])
					[menuItem setState:NSOnState];
				[appsmenu addItem:menuItem];
				[menuItem release];
			}
		}
	}
}

- (void)selectLanguage:(id) sender
{
	NSArray * languages = [self languages];
	NSString * language = [sender representedObject];
	int indexOfLanguage = [languages indexOfObjectIdenticalTo:language];
	if( indexOfLanguage != NSNotFound )
	{
		NSMutableArray * newLanguages = [[languages mutableCopy] autorelease];
		[newLanguages removeObjectAtIndex:indexOfLanguage];
		[newLanguages insertObject:language atIndex:0];
		[self setLanguages:newLanguages];
		[self menuNeedsUpdate:langmenu];
		
		NSString * appname;
		NSEnumerator * appEnum = [appsToRelaunch objectEnumerator];
		while( (appname=[appEnum nextObject])!=nil )
		{
			NSString * source = [NSString stringWithFormat:@"tell application \"%@\"\n quit\n delay 0.5\n activate\n end tell",appname];
			NSDictionary * error;
			[[[[NSAppleScript alloc]initWithSource:source]autorelease] executeAndReturnError:&error];
		}
	}
}
- (void)setRelaunchApp:(id) sender
{
	if([appsToRelaunch containsObject:[sender representedObject]])
		[appsToRelaunch removeObject:[sender representedObject]];
	else
		[appsToRelaunch addObject:[sender representedObject]];
}

@end
