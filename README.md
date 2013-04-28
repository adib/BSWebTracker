# BSWebTracker

If you're developing mobile applications and want to know how many people actually using it, there are a number of analytics services options that you can use. Unfortunately that's not the case for desktop applications and thus I had to roll out my own solution.

`BSWebTracker` allows you to track how many active users you have and what functionalities that they're really using in your Mac OS X application. It does its work by pinging a designated web page and have Google Analytics do the hard work of collecting your app's usage data and generating useful reports for you to consume. Although engineered for Google Analytics, you can adapt this to use other analytics solutions (e.g. Adobe's SiteCatalyst -- previously known as Omniture).

A large part of this library was inspired by [doo's `GAJavaScriptTracker`](https://github.com/doo/GAJavaScriptTracker) – another open-source desktop analytics library – which I tried to use but couldn't make it work. I suspect the problem arises from doo's solution needing a local copy of Google Analytics' JavaScript library and running it from a temporary local file. The local copy may be obsolete or Google may have changed something which breaks reporting when the tracking script is executed from a local file. In contrast `BSWebTracker` should be more resilient to changes in Google's part since from their perspective it's not much different than a regular user loading a web page.

I wrote this library mostly for use in [Scuttlebutt](http://scuttlebuttapp.com) – our Yammer client for the Mac. As of this writing, the library doesn't handle error or no-network conditions. Thus it may "lose" analytics data if either the network or your web server is down. Nevertheless it's sufficient for our own current use.

## Server Setup

You'll need to have a Google Analytics account and a website that will receive the analytics data. There is a sample HTML file in the `public_html` folder that you can use. Update your Google Analytics tracking ID into that file and upload it to your web server before starting.

There is a bundled sample application that you can use to verify your setup:

1. Run the bundled `TestApp` application using Xcode.
2. In the app, point *Tracking URL* to your web server and the path that you've uploaded the HTML file that contains your tracking ID. 
3. Click on *Track* to test hitting your web server. 
4. Log in to Google Analytics and go to the *Real Time Overview* section.
5. Verify that you can see your own tracking results. 
6. Try to change some of the parameters and click *Track* again to see how it gets reflected in Google Analytics' reports.

## Project Setup

1. Add `WebTracker.xcodeproj` as a dependent to your project.
2. Link your app with the provided `libWebTracker.a` static library.
3. Make sure that your app is also linked with these system frameworks:
  * `WebKit.framework`
  * `IOKit.framework`
4. Include `BSWebTracker.h` in your primary project's header search path.


## Usage

Create an instance of `BSWebTracker` class and keep it around as long as you want to track user actions. You'll probably want to make this a singleton or wrap it in your own singleton. Only use the instance **from the main queue** and don't use it in background threads.

This sample code should get you started.

    #import "BSWebTracker.h"
     ...
    BSWebTracker* tracker = [BSWebTracker new];
    // point the URL to your web server.
    tracker.trackerURLString = @"http://example.com/tracker/";
    [tracker trackName:@"anAction" content:nil term:nil];
    
Again, play around with the bundled test application and see how it looks in your reports.

`BSWebTracker` keeps an invisible `WebView` object and only keep it alive as long as there are pending analytics requests to send. When it's done sending requests, the `WebView` object will be discarded automatically and will be recreated as soon as there are requests to send.


## Open Items

Currently the class doesn't handle offline conditions or website outages. Thus requests that don't make it to the server aren't retried and won't register as a "hit" to your server.

## License

This project is licensed under the BSD license. Please let me ([Sasmito Adibowo](mailto:adib@cutecoder.org)) know if you use it for something interesting.
