//
//  LanguageMenu.h
//  LanguageMenu
//
//  Created by Nicolas Bouilleaud on 23/01/08.
//

#import <Cocoa/Cocoa.h>


@interface LanguageMenu : NSObject {
	NSStatusItem *		statusItem;
	NSMenu *			langmenu;
	NSMenu *			appsmenu;
	NSMutableArray *	appsToRelaunch;
}

@end
