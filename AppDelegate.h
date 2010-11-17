//
//  AppDelegate.h
//  App With Preferences
//
//  Created by Steve Mcferrin on 11/17/10.
//  Copyright 2010 MacFlite Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

// Show preference window 
- (void)showPreferences:(id)sender;

@end
