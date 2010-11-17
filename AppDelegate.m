//
//  AppDelegate.m
//  App With Preferences
//
//  Created by Steve Mcferrin on 11/17/10.
//  Copyright 2010 MacFlite Software. All rights reserved.
//

#import "AppDelegate.h"
#import "UpdatePaneViewController.h"
#import "AccountsPaneViewController.h"

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	UpdatePaneViewController *updatePane = [[UpdatePaneViewController alloc] initWithNibName:@"UpdatePaneViewController" bundle:nil];
	AccountsPaneViewController *accountsPane = [[AccountsPaneViewController alloc] initWithNibName:@"AccountsPaneViewController"	bundle:nil];
	
	
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:updatePane, accountsPane, nil]];
	
}

- (void)showPreferences:(id)sender
{
	[[MBPreferencesController sharedController] showWindow:sender];
}
@end
