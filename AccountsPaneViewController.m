//
//  AccountsPaneViewController.m
//  App With Preferences
//
//  Created by Steve Mcferrin on 11/17/10.
//  Copyright 2010 MacFlite Software. All rights reserved.
//

#import "AccountsPaneViewController.h"


@implementation AccountsPaneViewController

- (NSString *)title
{
	return @"Accounts";
}

- (NSString *)identifier
{
	return @"AccountsPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"accounts"];
}

@end
