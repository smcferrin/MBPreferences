//
//  UpdatePreferenceViewController.m
//  App With Preferences
//
//  Created by Steve Mcferrin on 11/17/10.
//  Copyright 2010 MacFlite Software. All rights reserved.
//

#import "UpdatePaneViewController.h"


@implementation UpdatePaneViewController

- (NSString *)title
{
	return @"Update";
}

- (NSString *)identifier
{
	return @"UpdatePane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"update"];
}


@end
