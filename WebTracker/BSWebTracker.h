//
//  BSWebTracker.h
//  WebTracker
//
//  Created by Sasmito Adibowo on 27-04-13.
//  Copyright (c) 2013 Basil Salad Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSWebTracker : NSObject

@property (nonatomic,strong) NSString* trackerURLString;

-(void) trackName:(NSString*) campaignName content:(NSString*) campaignContent term:(NSString*) campaignTerm;

@end
