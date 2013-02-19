/*
 Copyright (c) 2008 Matthew Ball - http://www.mattballdesign.com
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MBPreferencesController.h"

NSString *MBPreferencesSelectionAutosaveKey = @"MBPreferencesSelection";

@interface MBPreferencesController (Private)
- (void)setupToolbar;
- (void)selectModule:(NSToolbarItem *)sender;
- (void)changeToModule:(id<MBPreferencesModule>)module;
@end

@implementation MBPreferencesController

#pragma mark -
#pragma mark Life Cycle

- (id)init
{
	if (self = [super init]) {
		NSWindow *prefsWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 300, 200) styleMask:(NSTitledWindowMask | NSClosableWindowMask) backing:NSBackingStoreBuffered defer:YES];
		[prefsWindow setShowsToolbarButton:NO];
		self.window = prefsWindow;
		
		[self setupToolbar];
	}
	return self;
}

static MBPreferencesController *sharedPreferencesController = nil;

+ (MBPreferencesController *)sharedController
{
    static dispatch_once_t pred;
    static MBPreferencesController *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[MBPreferencesController alloc] init];
    });
    
	return shared;
}

#pragma mark -
#pragma mark NSWindowController Subclass

- (void)showWindow:(id)sender
{
	[self.window center];
	[super showWindow:sender];
}

#pragma mark -
#pragma mark NSToolbar

- (void)setupToolbar
{
	NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"PreferencesToolbar"];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	[toolbar setAllowsUserCustomization:NO];
	[toolbar setDelegate:self];
	[toolbar setAutosavesConfiguration:NO];
	[self.window setToolbar:toolbar];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	NSMutableArray *__weak identifiers = [NSMutableArray array];
    [self.modules enumerateObjectsUsingBlock:^(id<MBPreferencesModule> module, NSUInteger idx, BOOL *stop) {
        [identifiers addObject:[module identifier]];
    }];
	
	return identifiers;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	// We start off with no items. 
	// Add them when we set the modules
	return nil;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	id<MBPreferencesModule> module = [self moduleForIdentifier:itemIdentifier];
	
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	if (module == nil)
		return item;

	[item setLabel:[module title]];
	[item setImage:[module image]];
	[item setTarget:self];
	[item setAction:@selector(selectModule:)];
	return item;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [self toolbarAllowedItemIdentifiers:toolbar];
}

#pragma mark -
#pragma mark Modules

- (id<MBPreferencesModule>)moduleForIdentifier:(NSString *)identifier
{
    id __block retModule;
    [self.modules enumerateObjectsUsingBlock:^(id module, NSUInteger idx, BOOL *stop) {
        if ([[module identifier] isEqualToString:identifier]) {
            retModule = module;
		}
    }];
    
	return retModule;
}

- (void)setModules:(NSArray *)modules
{	
	if (modules != _modules) {
		_modules = modules;
		
		// Reset the toolbar items
		NSToolbar *__block toolbar = [self.window toolbar];
		if (toolbar != nil) {
			NSInteger index = [[toolbar items] count] -1;
			while (index > 0) {
				[toolbar removeItemAtIndex:index];
				index--;
			}
			
			// Add the new items
			for (id<MBPreferencesModule> module in _modules) {
				[toolbar insertItemWithItemIdentifier:[module identifier] atIndex:[[toolbar items] count]];
			}
		}
		
		// Change to the correct module
		if ([_modules count]) {
			id<MBPreferencesModule> defaultModule = nil;
			
			// Check the autosave info
			NSString *savedIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:MBPreferencesSelectionAutosaveKey];
			defaultModule = [self moduleForIdentifier:savedIdentifier];
			
			if (defaultModule != nil) {
				defaultModule = [_modules objectAtIndex:0];
			}
			
			[self changeToModule:defaultModule];
		}
	}
}

- (void)setSelectedPreferenceItemWithIdentifier:(NSString *)identifier
{
	[self changeToModule:[self moduleForIdentifier:identifier]];
}

- (void)selectModule:(NSToolbarItem *)sender
{
	if (![sender isKindOfClass:[NSToolbarItem class]])
		return;
	
	id<MBPreferencesModule> module = [self moduleForIdentifier:[sender itemIdentifier]];
	if (!module)
		return;
	
	[self changeToModule:module];
}

- (void)changeToModule:(id<MBPreferencesModule>)module
{
	[[self.currentModule view] removeFromSuperview];
	
	NSView *newView = [module view];
	
	// Resize the window
	NSRect newWindowFrame = [self.window frameRectForContentRect:[newView frame]];
	newWindowFrame.origin = [self.window frame].origin;
	newWindowFrame.origin.y -= newWindowFrame.size.height - [self.window frame].size.height;
	[self.window setFrame:newWindowFrame display:YES animate:YES];
	
	[[self.window toolbar] setSelectedItemIdentifier:[module identifier]];
	[self.window setTitle:[module title]];
	
	if ([(NSObject *)module respondsToSelector:@selector(willBeDisplayed)]) {
		[module willBeDisplayed];
	}
	
	self.currentModule = module;
	[[self.window contentView] addSubview:[self.currentModule view]];
	
	// Autosave the selection
	[[NSUserDefaults standardUserDefaults] setObject:[module identifier] forKey:MBPreferencesSelectionAutosaveKey];
}

@end
