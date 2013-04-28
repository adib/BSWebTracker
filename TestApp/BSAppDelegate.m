//
//  BSAppDelegate.m
//  WebTracker
//
//  Created by Sasmito Adibowo on 27-04-13.
//  Copyright (c) 2013 Basil Salad Software. All rights reserved.
//

#import "BSAppDelegate.h"
#import "BSWebTracker.h"

@interface BSAppDelegate ()

@property (nonatomic,strong) BSWebTracker* webTracker;

@end

@implementation BSAppDelegate

#pragma mark Property Access


-(BSWebTracker *)webTracker
{
    if (!_webTracker) {
        _webTracker = [BSWebTracker new];
    }
    return _webTracker;
}

#pragma mark NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

#pragma mark Action Handlers

- (IBAction)track:(id)sender
{
    BSWebTracker* tracker = self.webTracker;
    tracker.trackerURLString = self.trackingURLTextField.stringValue;
    [tracker trackName:self.campaignContentTextField.stringValue content:self.campaignContentTextField.stringValue term:self.campaignTermTextField.stringValue];
}
@end
