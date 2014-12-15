/*
     File: AppDelegate.m 
 Abstract: The application delegate class used for installing our main navigation controller.
  
  Version: 1.2 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import "AppDelegate.h"
#import "MyViewController.h"

@interface AppDelegate ()
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property BOOL startedFromScratch;
@end

@implementation AppDelegate;
@synthesize theEmailedFile,theInitiatingApp;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
   
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if(_allowToLaunch == false) {
        NSFileManager *fileManager = [NSFileManager defaultManager];  // mail puts a COLPY in %@/Documents/Inbox/",NSHomeDirectory()];
        [fileManager removeItemAtURL:url error:nil];
        [self MyAlertWithError:@"" theMessage:@"Please Exit to the Welcome Screen\nin PuzlPic before trying\nto view a new Puzzle\nfrom another app!"];
        return false;
    }
//   [self MyAlertWithError:@"Position 1" theMessage:@"Take note"];
    if(_startedFromScratch)
        _startedFromScratch = false;
    else {
        self.theEmailedFile = url;
        self.theInitiatingApp = sourceApplication;
        MyViewController *controller;
//        navigationController = [[rootController viewControllers] objectAtIndex:0];  we not using a nav controller???
        controller = (MyViewController *)self.navController.topViewController;
        if(url != nil)
            [controller DoEmailedPuzzle];
    }
    return true;
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.theEmailedFile = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    self.theInitiatingApp = (NSString *)[launchOptions valueForKey:UIApplicationLaunchOptionsSourceApplicationKey];
/*
    NSLog(@"the url %@ and the initiating app is %@", [self.theEmailedFile path],self.theInitiatingApp);
    if(![self.theEmailedFile isFileURL])
        NSLog(@"the url is not a file");
    if([self.theEmailedFile isFileReferenceURL])
        NSLog(@"the url IS A FILE REF URL");
*/
//   [self MyAlertWithError:@"Position 2" theMessage:@"Take note"];
    _allowToLaunch = _startedFromScratch = true;
    if(self.theEmailedFile == nil)
        _startedFromScratch = false;
	CGRect screenBounds = [ [ UIScreen mainScreen ] bounds ];
    _window = [[UIWindow alloc] initWithFrame: screenBounds];
    self.window.rootViewController = self.navController;
	[self.window makeKeyAndVisible];
    return true;
}

- (void)dealloc
{
	[_navController release];
    [_window release];
	
    [super dealloc];
}

/*------------------------------------------------
 display an error screen
 the message returned by NSERROR is not adequate to describe the problem
 NSString *message = [NSString stringWithFormat:@"Error! %@ %@",[theError localizedDescription],[theError localizedFailureReason]];
 -------------------------------------------------*/
-(void) MyAlertWithError:(NSString *)theTitle theMessage:(NSString *)theError {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:theTitle
													message:theError
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
    
    return;
}
/**************************************************************
 callback for alert view
 *************************************************************/
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    return;
}
/************************************************
all this now from FTPSample or NSstream sample or coredatabooks sample
***************************************************/
+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}
//---------------------------------------------------------------
//---------------------------------------------------------------
-(NSString *)pathForBundleFiles {
    NSString *          filePath;
    NSFileManager *     fileManager;
    NSDictionary *      attrs;
    unsigned long       fileSize;
    
    
    filePath = [[NSBundle mainBundle] pathForResource:@"800-stop.png" ofType:@"png"];
    
    fileManager = [NSFileManager defaultManager];
    attrs = [fileManager attributesOfItemAtPath:filePath error:NULL];
    fileSize = [[attrs objectForKey:NSFileSize] unsignedLongValue];
    fileSize = fileSize;
    return filePath;
}

/**************** taken from park project ****************************/
/**************** taken from park project ****************************/
/**************** taken from park project ****************************/
/**************** taken from park project ****************************/
- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

@end
