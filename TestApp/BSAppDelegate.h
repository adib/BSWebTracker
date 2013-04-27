//
//  BSAppDelegate.h
//  WebTracker
//
//  Created by Sasmito Adibowo on 27-04-13.
//  Copyright (c) 2013 Basil Salad Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BSAppDelegate : NSObject <NSApplicationDelegate>

@property (assign,nonatomic) IBOutlet NSWindow *window;
@property (weak,nonatomic) IBOutlet NSTextField *trackingURLTextField;
@property (weak,nonatomic) IBOutlet NSTextField *campaignNameTextField;
@property (weak,nonatomic) IBOutlet NSTextField *campaignContentTextField;
@property (weak,nonatomic) IBOutlet NSTextField *campaignTermTextField;
- (IBAction)track:(id)sender;

@end
