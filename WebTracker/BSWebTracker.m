//
//  BSWebTracker.m
//  WebTracker
//
//  Created by Sasmito Adibowo on 27-04-13.
//  Copyright (c) 2013 Basil Salad Software. All rights reserved.
//

#import <IOKit/IOKitLib.h>
#import <WebKit/WebKit.h>

#if !__has_feature(objc_arc)
#error Need automatic reference counting to compile this.
#endif

#import "BSWebTracker.h"


@interface BSWebTracker ()

@property (nonatomic,strong,readonly) NSString* trackingMedium;

@property (nonatomic,strong,readonly) NSString* trackingSource;

@property (nonatomic,strong,readonly) WebView* webView;

@property (nonatomic,strong,readonly) NSMutableArray* trackerURLQueue;

@end

// ---

NSString* const BSWebTrackerFlushQueueNotification = @"com.basilsalad.BSWebTrackerFlushQueueNotification";

// ---
@implementation BSWebTracker

-(void) handleFlushQueue:(NSNotification*) notification
{
    NSMutableArray* queue = self.trackerURLQueue;
    if (queue.count > 0) {
        if ([_webView isLoading]) {
            // retry later
            [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle];
            return;
        }
        NSURL* url = queue[0];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [self.webView.mainFrame loadRequest:request];
    } else if (![_webView isLoading]) {
        // no more queued requests & web view isn't doing anything - clean up the web view
        [self cleanupWebView];
    }
}

-(void) notifyFlushQueue
{
    NSNotification* notification = [NSNotification notificationWithName:BSWebTrackerFlushQueueNotification object:self];
    [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle];
}


-(void) queueURL:(NSURL*) url
{
    if (url) {
        [self.trackerURLQueue addObject:url];
        [self notifyFlushQueue];
    }
}


-(void) dequeueURL
{
    // TODO: handle reachability, sleep/wake, etc – make it more resilient
    NSMutableArray* queue = self.trackerURLQueue;
    if (queue.count > 0) {
        [queue removeObjectAtIndex:0];
    }

    // either handle more requests or cleanup the web view.
    [self notifyFlushQueue];
    
}

-(void) cleanupWebView
{
    if (_webView) {
        [_webView stopLoading:nil];
        _webView.frameLoadDelegate = nil;
        _webView = nil;
    }
}


-(void) trackName:(NSString*) campaignName content:(NSString*) campaignContent term:(NSString*) campaignTerm
{
    NSString* trackerURLString = self.trackerURLString;
    if (!trackerURLString) {
        return;
    }
    if (campaignName.length == 0) {
        // campaign name is required. So we just plug in the current date here.
        //Sample date: "Tue May 17 06:18:25 +0000 2011" (used by Twitter)
        NSDateFormatter* fmt = [NSDateFormatter new];
        fmt.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy";
        campaignName = [fmt stringFromDate:[NSDate date]];
    }
    NSMutableString* urlString = [NSMutableString stringWithFormat:@"%@?utm_source=%@&utm_medium=%@&utm_campaign=%@",trackerURLString,[self.trackingSource stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.trackingMedium stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[campaignName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (campaignContent.length > 0) {
        [urlString appendFormat:@"&utm_content=%@",[campaignContent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    if (campaignTerm.length > 0) {
        [urlString appendFormat:@"&utm_term=%@",[campaignTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSURL* url = [NSURL URLWithString:urlString];
    [self queueURL:url];
}

#pragma mark NSObject

-(id)init
{
    if ((self = [super init])) {
        NSNotificationCenter* defaultNC = [NSNotificationCenter defaultCenter];
        [defaultNC addObserver:self selector:@selector(handleFlushQueue:) name:BSWebTrackerFlushQueueNotification object:self];
    }
    return self;
}

-(void)dealloc
{
    [self cleanupWebView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Property Access

// tracking medium is the machine

@synthesize trackingMedium = _trackingMedium;

-(NSString *)trackingMedium
{
    if (!_trackingMedium) {
        // http://stackoverflow.com/questions/5868567/unique-identifier-of-a-mac
        io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                                     
                                                                     IOServiceMatching("IOPlatformExpertDevice"));
        CFStringRef serialNumberAsCFString = NULL;
        
        if (platformExpert) {
            serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,
                                                                     CFSTR(kIOPlatformSerialNumberKey),
                                                                     kCFAllocatorDefault, 0);
            IOObjectRelease(platformExpert);
        }
        
        NSString *serialNumberAsNSString = nil;
        if (serialNumberAsCFString) {
            serialNumberAsNSString = [NSString stringWithString:(__bridge NSString *)serialNumberAsCFString];
            CFRelease(serialNumberAsCFString);
        }
        
        if (!serialNumberAsNSString) {
            NSHost* host = [NSHost currentHost];
            serialNumberAsNSString = [[host name] copy];
        }
        if (serialNumberAsNSString.length == 0) {
            serialNumberAsNSString = @"(unknown)";
        }
        _trackingMedium = serialNumberAsNSString;
    }
    return _trackingMedium;
}


// tracking source is the main app's bundle ID

@synthesize trackingSource = _trackingSource;

-(NSString *)trackingSource
{
    if (!_trackingSource) {
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSDictionary* infoDictionary = mainBundle.infoDictionary;
        _trackingSource = [NSString stringWithFormat:@"%@ (%@)",infoDictionary[(__bridge id) kCFBundleIdentifierKey],infoDictionary[(__bridge id)kCFBundleVersionKey]];
    }
    return _trackingSource;
}


@synthesize webView = _webView;

-(WebView *)webView
{
    if (!_webView) {
        _webView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, 320, 200) frameName:nil groupName:nil];
        _webView.frameLoadDelegate = self;
    }
    return _webView;
}

@synthesize trackerURLQueue = _trackerURLQueue;

-(NSMutableArray *)trackerURLQueue
{
    if (!_trackerURLQueue) {
        _trackerURLQueue = [NSMutableArray new];
    }
    return _trackerURLQueue;
}

#pragma mark WebFrameLoadDelegate

- (void)webView:(WebView *)webView didStartProvisionalLoadForFrame:(WebFrame *)webFrame
{
    
}

- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)webFrame
{
    if (webFrame == webView.mainFrame) {
        [self dequeueURL];
    }
}

- (void)webView:(WebView *)webView didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)webFrame
{
    if (webFrame == webView.mainFrame) {
        [self dequeueURL];
    }
}

@end


