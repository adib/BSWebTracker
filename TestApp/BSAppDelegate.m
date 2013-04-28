//
//  BSAppDelegate.m
//  WebTracker
//
//  Created by Sasmito Adibowo on 27-04-13.
//  Copyright (c) 2013 Basil Salad Software. All rights reserved.
//  http://basilsalad.com
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
