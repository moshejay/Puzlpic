/*
     File: MyViewController.m 
 Abstract: The main view controller of this app.
  
  Version: 1.2 
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
  
 */
#import "AppDelegate.h"
#import "MyViewController.h"
#import "SettingsViewController.h"
//#import "NewSettingsViewController.h"
#include "TableSettingsController.h"
//#import "HelpViewController.h"
#import "HelpTableTableViewController.h"
#import "RcvdPicsTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface MyViewController ()
@property (nonatomic, retain) IBOutlet UILabel *welcome1,*welcome2,*welcome4;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIToolbar *myToolbar;
@property (nonatomic, retain) OverlayViewController *overlayViewController;
@property (nonatomic, retain) JumbleViewController *jumbleViewController;
@property (nonatomic, retain) UIPopoverController *iPadPhotoPicker;
@property (nonatomic, retain) UIImage *imageToUse,*jumbledImage;
@property (nonatomic, retain) NSTimer *tickTimer;
@property (assign) bool alphaIsDropping;
@property (assign) int acount;
@property BOOL doneOnce;

// toolbar buttons
- (IBAction)photoLibraryAction:(id)sender;
- (IBAction)cameraAction:(id)sender;
-(IBAction)jumblePic:(id)sender;
-(IBAction)preJumbledPic:(id)sender;
-(IBAction)DoSettings:(id)sender;
-(IBAction)helpAction:(id)sender;
-(IBAction)DoSavedFiles:(id)sender;
-(IBAction)DoSavedReceivedFiles:(id)sender;

- (void) timedFire:(NSTimer *)timer;
- (void) DoAnEmailedPuzzle;
- (void) MyAlertWithError:(NSString *)theTitle theMessage:(NSString *)theError;
- (void)LoadThePreJumbledPic:(NSString *)theFilePath;
-(BOOL)CheckThePreJumbledPic:(NSData *) theData  showAnAlert:(BOOL)showAlert;

@end

@implementation MyViewController


#pragma mark -
#pragma mark View Controller

- (void)viewDidLoad
{
    self.overlayViewController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
    self.overlayViewController.delegate = self; // as a delegate we will be notified when pictures are taken and when to dismiss the image picker
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])    {
        NSMutableArray *toolbarItems = [NSMutableArray arrayWithCapacity:self.myToolbar.items.count]; // if camera not on device don't show camera button
        [toolbarItems addObjectsFromArray:self.myToolbar.items];
        [toolbarItems removeObjectAtIndex:0];
        [self.myToolbar setItems:toolbarItems animated:NO];
    }
    self.jumbleViewController = [[[JumbleViewController alloc] initWithNibName:@"JumbleViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.jumbleViewController.delegate = self;
    self.welcome4.hidden = true;
//    self.welcome2.hidden = true;

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGPoint apoint = self.view.center;
        if(self.interfaceOrientation == UIDeviceOrientationLandscapeLeft || self.interfaceOrientation == UIDeviceOrientationLandscapeRight) {
            apoint.x += self.welcome1.frame.size.width/4;  // these are very different to the lite ver!!!
            apoint.y -= self.welcome1.frame.size.height;
        }
        else
            apoint.y -= self.welcome1.frame.size.height/2;
        self.welcome1.center = apoint;
        self.welcome2.center = apoint;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = @"";
    
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/Received",NSHomeDirectory()];
    [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    filePath = @"";
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/Sent",NSHomeDirectory()];
    [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    [self StartTheTimer];
    return;
}

- (void)viewDidUnload
{
    self.jumbledImage = nil;
    self.imageView = nil;
    self.myToolbar = nil;
    self.overlayViewController = nil;
    self.imageToUse = nil;
    self.jumbleViewController = nil;
    _welcome1  = nil;
    _welcome2  = nil;
    _welcome4  = nil;
    _iPadPhotoPicker = nil;
    _tickTimer = nil;
    
    return;
}

- (void)dealloc
{	
	[_imageView release];
	[_myToolbar release];
    
    [_overlayViewController release];
//	[_capturedImages release];
    if(self.imageToUse != nil)
        [_imageToUse release];
    if(self.jumbledImage != nil)
        [_jumbledImage release];
    [_jumbleViewController release];
    
    [_welcome1 release];
    [_welcome2 release];
    [_welcome4 release];
    [_iPadPhotoPicker release];
    if(_tickTimer != nil)
        [_tickTimer release];
    
    [super dealloc];
}

//----------------------------------------------------
// view has just appeared
//------------------------------------------------------
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AppDelegate sharedAppDelegate].allowToLaunch = true;
    if(_doneOnce)         // so only do the following loadings once per launch
        return;
    _doneOnce = true;
    
     NSURL *aurl = [AppDelegate sharedAppDelegate].theEmailedFile;
     if(aurl == nil)
         return;
/*
    NSString *astr = @"";
    NSString *bstr = @"";
    astr = [NSString stringWithCString:[aurl fileSystemRepresentation] encoding:NSUTF8StringEncoding];
    bstr = [bstr stringByAppendingFormat:@"looky....%@",[AppDelegate sharedAppDelegate].theInitiatingApp]; // mail app is "com.apple.mobilemail" & safari is "com.apple.mobilesafari"
    [self MyAlertWithError:bstr theMessage:astr];
*/
    [self DoEmailedPuzzle];

    return;
}
//----------------------------------------------------
// view has just DISappeared
//------------------------------------------------------
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [AppDelegate sharedAppDelegate].allowToLaunch = false;
    return;
}
/************************************
 what to do if rotate phone
 ***********************************/
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGPoint apoint = self.view.superview.center;
        if(toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight) {
            apoint.x += self.welcome1.frame.size.width/2; // note these are very different to the lite ver.....!!!!
            apoint.y -= self.welcome1.frame.size.height;
        }
        else
            apoint.x -= self.welcome1.frame.size.width/2;
        self.welcome1.center = apoint;
        self.welcome2.center = apoint;
    }
    return;
}

#pragma mark -
#pragma mark Toolbar Actions
/*****************************************
 pressed settings button
 ******************************************/
-(IBAction)DoSettings:(id)sender {

//    SettingsViewController *newSettingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    NewSettingsViewController *newSettingsViewController = [[NewSettingsViewController alloc] initWithNibName:@"NewSettingsViewController" bundle:nil];
//    SettingsViewController *newSettingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    TableSettingsController *newSettingsViewController = [[TableSettingsController alloc] initWithStyle:UITableViewStyleGrouped];
    
    [self.navigationController pushViewController:newSettingsViewController animated:YES];
    [newSettingsViewController release];
    return;
}
/*****************************************
 pressed saved files button
 ******************************************/
-(IBAction)DoSavedFiles:(id)sender {
    
    RcvdPicsTableViewController *rpicsViewController = [[RcvdPicsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    rpicsViewController.lookAtSent = TRUE;
    [self.navigationController pushViewController:rpicsViewController animated:YES];
    [rpicsViewController release];
    return;
}
/*****************************************
 pressed saved files button
 ******************************************/
-(IBAction)DoSavedReceivedFiles:(id)sender {
    
    RcvdPicsTableViewController *rpicsViewController = [[RcvdPicsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    rpicsViewController.lookAtSent = FALSE;
    [self.navigationController pushViewController:rpicsViewController animated:YES];
    [rpicsViewController release];
    return;
}
/*****************************************
 pressed help button
 ******************************************/
- (IBAction)helpAction:(id)sender
{
    HelpTableTableViewController *hvc = [[HelpTableTableViewController alloc] initWithNibName:@"HelpTableTableViewController" bundle:nil];
    [self.navigationController pushViewController:hvc animated:YES];
    [hvc release];
    return;
}
/************************************************
 pressed image picker btn...note difference for ipad
 On the iPad we need to present the image picker in a popover....see proj PrintPhoto printphotoViewController.m
 but only when looking at albums or camera roll. For camera we want the old way.
 *************************************************/
- (IBAction)photoLibraryAction:(id)sender
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if(self.iPadPhotoPicker){
            // If a popover is already showing, dismiss it before presenting a new one.
            [self.iPadPhotoPicker dismissPopoverAnimated:YES];
            self.iPadPhotoPicker = nil;
//            return;
        }

//        if(self.welcome1.hidden == false)
//            self.welcome1.hidden = self.welcome2.hidden = true;
        
        if (self.imageView.isAnimating)
            [self.imageView stopAnimating];
//        self.imageToUse = nil;
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;

        // We own this instance of the popover controller but will release it in popoverControllerDidDismissPopover.
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        popoverController.delegate = self;
        self.iPadPhotoPicker = popoverController;
        [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [imagePicker release];
    }
    else
        [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    
    return;
}
/************************************************
 pressed image picker btn
 *************************************************/
- (IBAction)cameraAction:(id)sender
{
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
    return;
}
/************************************************
 common func for selection
 *************************************************/
- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    
//    if(self.welcome1.hidden == false)
//        self.welcome1.hidden = self.welcome2.hidden = true;
    
    if (self.imageView.isAnimating)
       [self.imageView stopAnimating];
//    self.imageToUse = nil;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        [self.overlayViewController setupImagePicker:sourceType];
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:self.overlayViewController.imagePickerController animated:YES completion:NULL];
    }
    
    return;
}
#pragma mark -
#pragma mark delagate for popover & ipad imagepicker
/*************************************************
*************************************************/
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.iPadPhotoPicker = nil;
    return;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil]; // deprecated dismissModalViewControllerAnimated
    return;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Don't pay any attention if somehow someone picked something besides an image.
    if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]){
        self.imageToUse = [info valueForKey:UIImagePickerControllerOriginalImage];
        [self.imageView setImage:self.imageToUse];
        [self.iPadPhotoPicker dismissPopoverAnimated:YES];
        if ([self.tickTimer isValid]) { // stop the timer
            [self.tickTimer invalidate];
            _tickTimer = nil;
            self.welcome1.hidden = self.welcome2.hidden = true;
        }
    }
    return;
}

#pragma mark -
#pragma mark OverlayViewControllerDelegate
/*************************************************
 called back from overlayViewController
 cos we the delegate 
**************************************************/
- (void)didTakePicture:(UIImage *)picture
{
    self.imageToUse = picture;
    return;
}
/*****************************************
 called back from overlayViewController
cos we the delegate 
******************************************/
- (void)didFinishWithCamera
{

    [self dismissViewControllerAnimated:YES completion:nil]; // deprecated dismissModalViewControllerAnimated

    if(self.imageToUse != nil) {
        [self.imageView setImage:self.imageToUse];
        if ([self.tickTimer isValid]) { // stop and reset the timer
            [self.tickTimer invalidate];
            _tickTimer = nil;
            self.welcome1.hidden = self.welcome2.hidden = true;
        }
    }

    return;
}
/****************************************
 now split the image into however many tiles & create the puzzle
 ********************************************/
-(IBAction)jumblePic:(id)sender {
    
    if(self.imageToUse == nil)
    {
        [self MyAlertWithError:@"" theMessage:@"Select a picture or Use the Camera to take a picture!"];
        return;
    }

    [self.jumbleViewController SetupTheImage:self.imageToUse];
    
    bool touchMsgOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicTouchMsgOff"] ^ 1; // note the converse in case not exist
/*
To display or hide the toolbar,\n
touch the little dasboard icon\n
near the bottom of the screen.\n
And to stop seeing this\n
message, touch 'settings' on\n
the previous screen, then\n
touch the 'system' row.
*/
    
    if(touchMsgOn)
        [self MyAlertWithError:@"" theMessage:@"To display or hide the toolbar,\ntouch the little arrow icon\nnear the bottom of the screen.\nAnd to stop seeing this\nmessage, touch 'settings' on\nthe previous screen, then\ntouch the 'system' row."];

//    [self.navigationController pushViewController:self.jumbleViewController animated:YES];
/*** use modal views cos the nav view not needed ***/
    [self presentViewController:self.jumbleViewController animated:YES completion:NULL]; // presentModalViewController is deprecated
    [self.jumbleViewController SetupTheView];
    return;
}
/***********************************************
 we are using a puzzle someone sent us
 **********************************************/
-(void) DoEmailedPuzzle {

    /******* grab the image from our inbox **************/
    NSString *filePath = @"";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL aret;
    
    NSData *theData = [NSData dataWithContentsOfURL:[AppDelegate sharedAppDelegate].theEmailedFile];
    aret = [self CheckThePreJumbledPic:theData showAnAlert:FALSE];     // we are not concerned whether it has an attached complete image but are concerned about version.
    NSString *recvdFile = [[AppDelegate sharedAppDelegate].theEmailedFile lastPathComponent];  //filename + extension
    
    [fileManager removeItemAtURL:[AppDelegate sharedAppDelegate].theEmailedFile error:nil];
    if(!aret)    // return only AFTER deleting what the email client put...else we end up with copies
        return;
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/Received/LastReceivedPuzzle.pzlpic",NSHomeDirectory()];
    if([fileManager createFileAtPath:filePath contents:theData attributes:nil] == false) {
        [self MyAlertWithError:@"File Error" theMessage:@"Cannot Recreate Data File.\nPlease inform Support"]; // and now??
        return;
    }
    self.jumbleViewController.recvdFileName = recvdFile;
    self.jumbleViewController.isRecvdImage = true;
    self.jumbleViewController.isSentImage = FALSE;
    [self LoadThePreJumbledPic:filePath];

    return;
}
/***********************************************
 we are opening a known file that mail deposited for us.
 no longer used...just note where email deposits an attachment
 **********************************************/
-(void) DoAnEmailedPuzzle {
    /******* grab the image from our inbox **************/
    NSFileManager *fileManager;
    fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = @"";
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/Inbox/myPicPuzl1.pzlpic",NSHomeDirectory()];
    
    NSData *theData = [NSData dataWithContentsOfFile:filePath];
    if(theData == nil) // no data
        return;
    
    [fileManager removeItemAtPath:filePath error:nil];
    
    filePath = @"";
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/ReceivedViews.pzlpic",NSHomeDirectory()];
    if([fileManager createFileAtPath:filePath contents:theData attributes:nil] == false) {
        [self MyAlertWithError:@"File Error" theMessage:@"Cannot Recreate Data File.\nPlease inform Support"]; // and now??
        return;
    }
    if([self CheckThePreJumbledPic:theData showAnAlert:TRUE])
        [self LoadThePreJumbledPic:filePath];
    return;
}
/***********************************************
 we are using a presaved puzzle
 **********************************************/
-(IBAction)preJumbledPic:(id)sender {

    /******* grab the image from our archive **************/
    NSString *filePath = @"";
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/MyzxzxPuzzle.pzlpic",NSHomeDirectory()];
    self.jumbleViewController.isRecvdImage = self.jumbleViewController.isSentImage = FALSE;

    NSData *theData = [NSData dataWithContentsOfFile:filePath];
    if([self CheckThePreJumbledPic:theData showAnAlert:TRUE])
        [self LoadThePreJumbledPic:filePath];
    return;
}
//--------------------------------------------
// common func...check the data is valid
//--------------------------------------------
-(BOOL)CheckThePreJumbledPic:(NSData *) theData  showAnAlert:(BOOL)showAlert{

    UIImage *animage = nil;
    NSInteger aval = 9999999;  //any big number
    if(theData != NULL) { // ver 1.2
        NSKeyedUnarchiver *theunarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
        animage = [theunarchive decodeObjectForKey:@"passed image image"];
        aval = [theunarchive decodeIntForKey:@"File Version"];
        [theunarchive finishDecoding];
        [theunarchive release];
    }
    if(animage == nil) {
        if(showAlert) {
            [self MyAlertWithError:@"" theMessage:@"No Picture Puzzle was previously saved!"];
            return false;
        }
    }
    if(aval > PUZLPIC_VER) { // will also be if data = null but that is trapped above
        [self MyAlertWithError:@"Version Error" theMessage:@"In order to view this puzzle\nyou must upgrade your\nversion of PuzlPic."];
        return false;
    }
    [self.jumbleViewController SetupTheImage:animage];
    return true;
}
//--------------------------------------------
// common func....to load a previously jumbled pic
// the filePath tells us which pic to use
//--------------------------------------------
-(void)LoadThePreJumbledPic:(NSString *)theFilePath {

    if ([self.tickTimer isValid]) // stop the timer
    {
        [self.tickTimer invalidate];
        _tickTimer = nil;
        self.welcome1.hidden = self.welcome2.hidden = true;
    }
    
    bool touchMsgOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicTouchMsgOff"] ^ 1; // note the converse in case not exist
    if(touchMsgOn)
        [self MyAlertWithError:@"" theMessage:@"To display or hide the toolbar,\ntouch the little arrow icon\nnear the bottom of the screen.\nAnd to stop seeing this\nmessage, touch 'settings' on\nthe previous screen, then\ntouch the 'system' row."];

    [self presentViewController:self.jumbleViewController animated:YES completion:NULL]; // presentModalViewController is deprecated
    [self.jumbleViewController DoTheWholeRestore:theFilePath];
    return;
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
/*****************************************
 called back from JumbleViewController
 cos we the delegate
 ******************************************/
- (void)didFinishWithJumbleView {

    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.imageToUse == nil) {
        [self StartTheTimer];
        self.welcome1.hidden = self.welcome2.hidden = false;
    }
    return;
}
/*****************************************
the timer set up
 ******************************************/
-(void)StartTheTimer {
    
if ([self.tickTimer isValid]) // stop and reset the timer
{
    [self.tickTimer invalidate];
    _tickTimer = nil;
}
    
    _tickTimer = [NSTimer scheduledTimerWithTimeInterval:0.2   // fire every 1/4 seconds
                                                  target:self
                                                  selector:@selector(timedFire:)
                                                  userInfo:nil
                                                  repeats:YES];
    self.alphaIsDropping = true;
    self.acount = 0;
    return;
}
/*****************************************
 called back from the timer on reacing timeout
 ******************************************/
- (void)timedFire:(NSTimer *)timer
{
    if(self.alphaIsDropping) {
        if(self.welcome2.alpha > 0.02)
            self.welcome2.alpha -= 0.02;
        else {
            if(self.acount++ >= 4) {
                self.acount = 0;
            self.alphaIsDropping = false;
            }
        }
    }
    else {
        if(self.welcome2.alpha < 0.98)
            self.welcome2.alpha += 0.02;
        else {
            if(self.acount++ >= 4) {
                self.acount = 0;
                self.alphaIsDropping = true;
            }
        }
    }
    return;
}

@end