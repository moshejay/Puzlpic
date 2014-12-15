//
//  JumbleViewViewController.m
//  PhotoPicker
//
//  Created by moshe jacobson on 23/03/13.
//
//
#import "AppDelegate.h"
#import "JumbleViewController.h"
#import "TileView.h"
#import <QuartzCore/QuartzCore.h>// Import QuartzCore for animations
#import <AudioToolbox/AudioServices.h>

#define THE_SHOWHIDE_BTN 999
#define THE_SHOWHIDE_BTN1 999 // the dn arrow
#define THE_SHOWHIDE_BTN2 998 // the up arrow
#define THE_TOOLBAR_CTRL 800
@interface JumbleViewController ()

@property (assign) SystemSoundID tickSound,dingSound,tadaSound,whooshSound;
@property (nonatomic, retain) UIImage *theImage,*theSmiley;
@property  CGRect smileyFrame;
@property (nonatomic, retain) TileView *touchedView;
@property (assign) BOOL isTouching,canLock,snapOnTouchEnded,puzlDone,tileSoundON,initialShowToolbar,canQuit,finishedItOnce,askingOrigImage,wantOrigImage,haveOriginal;
@property (assign) BOOL hiddenTilesMsgOn,quitMsgOn,saveMsgOn,hideOrigPicmsgOn,finshedPuzlSoundOn,toolBarSoundOn,peekPicOnTop;
@property (assign) float snapSensitivity,usedTilewidth,usedTileheight,usedWindowWidth,usedWindowHeight;
@property (assign) int viewCount,the_Visible_ShowHide_Btn_Tag;
@property (nonatomic, retain) IBOutlet UIToolbar *myToolbar;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *quitBtn,*saveBtn,*showHiddenTilesBtn,*showOrigPicBtn;
@property (retain, nonatomic) IBOutlet UILabel *imageNameLbl;
@property (retain, nonatomic) IBOutlet UITextField *imageNameTxtFld;
@property (retain, nonatomic) IBOutlet UIToolbar *theToolBar;

-(IBAction)DoQuitButton:(id)sender;
-(IBAction)DoHelpButton:(id)sender;
-(IBAction)DoShowButton:(id)sender;
-(IBAction)DoPeekButton:(id)sender;
-(IBAction)DoSaveButton:(id)sender;
- (IBAction)DoForwardPic:(id)sender;

- (BOOL)PerformTheActualSave:(BOOL)forSending includeOriginal:(BOOL)includeTheOriginal;
- (void)didFinishWithJumbleHelpView;
- (void) DoShowTheHiddenTiles;

- (void)MyAlertWithError:(NSString *)theTitle theMessage:(NSString *)theError;
-(void) DoSmsMessaging;
-(void) DoEmailMessaging;
-(void)StartTheFileNameTyping;
@end

@implementation JumbleViewController

@synthesize delegate,passedImage,theTouchPoint,isRecvdImage,isSentImage, recvdFileName;

#define GROW_ANIMATION_DURATION_SECONDS 0.15
#define MOVE_ANIMATION_DURATION_SECONDS 0.15

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      
    }
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:
                                               [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"aiff"]],&_tickSound);
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:
                                                [[NSBundle mainBundle] pathForResource:@"whoosh" ofType:@"aiff"]],&_whooshSound);
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:
                                                [[NSBundle mainBundle] pathForResource:@"tada" ofType:@"wav"]],&_tadaSound);
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:
                                                [[NSBundle mainBundle] pathForResource:@"ding" ofType:@"wav"]],&_dingSound);
    return self;
}
/********************************
 < 6.0
 doesn't seem to be called in ios6.0+ but check anyway
 *************************************/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        return NO;
    if(self.theImage.size.height > self.theImage.size.width)
    {
        if(interfaceOrientation == UIInterfaceOrientationPortrait)
            return YES;
        return NO;
    }
    if(interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        return NO;
    
    return YES;
}
/***********************************
 add  gesture here not in initWithNib
*********************************************/
- (void)viewDidLoad
{
    [super viewDidLoad];
    UILongPressGestureRecognizer *longPressGesture;    
    longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(theLongPressAction:)];
    longPressGesture.numberOfTouchesRequired = 2;
    longPressGesture.minimumPressDuration = 0.5;
    [self.view addGestureRecognizer:longPressGesture];
    [longPressGesture release];
     return;
}

/*****************************************
ios6+
 we don't want pic to rotate once we decided what orientation it is
 this is called after view presented & user decides to change device orientation
 ****************************************/
- (BOOL)shouldAutorotate {
    return NO;
}
/********************************************
 ios 6+
 for initial orientation
 **********************************************/
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    if(self.theImage.size.height > self.theImage.size.width) {
        if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
            return UIInterfaceOrientationPortrait;
    }
    else if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
       return UIInterfaceOrientationLandscapeRight;
    return [UIApplication sharedApplication].statusBarOrientation; // remain as is
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {

    self.theImage = nil;
    self.passedImage = nil;
    _myToolbar = nil;
    _tickSound = nil;
    _dingSound = nil;
    _whooshSound = nil;
    _tadaSound = nil;
    _touchedView = nil;
    [super viewDidUnload];
    return;
}

- (void)dealloc {
    [_theImage release];
    // [self.passedImage release]; we don't own it
    // [self.myToolbar release]; we don't own it
    for (TileView *aview in self.view.subviews) {
        if(aview.tag > 900)
            [aview removeFromSuperview];
    }
    //[self.touchedView release]; we dont own it
    AudioServicesDisposeSystemSoundID(_tickSound);
    AudioServicesDisposeSystemSoundID(_dingSound);
    AudioServicesDisposeSystemSoundID(_whooshSound);
    AudioServicesDisposeSystemSoundID(_tadaSound);
    [_imageNameLbl release];
    [_imageNameTxtFld release];
    [_theToolBar release];
    [super dealloc];
    return;
}

-(void) SetupTheImage:(UIImage *)imageToUse {
    self.theImage =  imageToUse;
    return;
}
/*********************************************
 one place to do the system settings
 ************************************************/
 -(void)GetAllTheSettings {
     self.canLock = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicLockTile"];
     self.snapOnTouchEnded = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicSnapTile"] ^ 1; //its the converse
     self.tileSoundON = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicSoundOff"] ^ 1;  //its the converse
     self.initialShowToolbar = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicPuzlToolbarOff"] ^ 1; //its the converse
     self.snapSensitivity = (float)[[NSUserDefaults standardUserDefaults] integerForKey:@"PuzlPicSnapSensitivity"];
     if(self.snapSensitivity < 1)
         self.snapSensitivity = 40.0;
     if(self.initialShowToolbar)
         self.myToolbar.hidden = false;

     self.hiddenTilesMsgOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicHiddenTilesMsgOff"] ^ 1;
     self.quitMsgOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicQuitMsgOff"] ^ 1;
     self.saveMsgOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicSaveMsgOff"] ^ 1;
     self.hideOrigPicmsgOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicOrigPicOff"] ^ 1;

     self.finshedPuzlSoundOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"FinishedPuzlPicSoundOff"] ^ 1;
     self.toolBarSoundOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicToolbarSoundOff"] ^ 1;
     self.peekPicOnTop = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicOnTheBot"] ^ 1;
     self.showOrigPicBtn.enabled = self.saveBtn.enabled = self.showHiddenTilesBtn.enabled = true;
     return;
 }
/***************************************************
 Do any additional setup called from viewDidLoad
 
 [self.passedImage setImage:self.theImage];  just to see the image
 UIImage *anyimage = [UIImage imageNamed:@"myplacard"];   just to create a temp image
 tempView.timage = anyimage;
        windowWidth = ((300.0 * windowHeight)/self.theImage.size.height) + 0.5;
 ***************************************************/
-(void) SetupTheView {

    int windowWidth,windowHeight,centre_x,centre_y;
    float tileWidth,tileHeight;
    UIImage *croppedimage,*tempImage;
    CGFloat virtualOrg_x,virtualOrg_y,drawATx,drawATy;
    CGRect frame;
    CGSize newSize;
    TileView *aView,*bview;
    
    self.myToolbar.hidden = self.passedImage.hidden = self.showHiddenTilesBtn.enabled = true;
    self.finishedItOnce = self.canQuit = self.puzlDone = false;
    self.haveOriginal = true;
    if([self.view.subviews count]) {
        for (UIView *aview in self.view.subviews) {
            if(aview.tag > 900) // remove all the views we programmatically add
                [aview removeFromSuperview];
        }
    }
        
    self.isTouching = false;
    
    NSInteger widthCnt,heightCnt,totalCnt;
    NSInteger longSide, shortSide;

    longSide = [[NSUserDefaults standardUserDefaults] integerForKey:@"PuzlPicLongSide"]; // returns 0 if not found
    shortSide = [[NSUserDefaults standardUserDefaults] integerForKey:@"PuzlPicShortSide"];
    [self GetAllTheSettings];
/*
    int anint;
    int bnint;
    anint = self.view.frame.size.height;
    bnint = self.view.frame.size.width;
    anint = self.theImage.size.height;
    bnint =  self.theImage.size.width;
*/
    if(self.view.frame.size.height > self.view.frame.size.width) { // the frame dims indicate portrait but orientation indicates landscape
        if(self.theImage.size.height > self.theImage.size.width) { // its a timing issue...go with frame dims.
            windowHeight = self.view.frame.size.height; //460 lose 20 for status
            windowWidth = self.view.frame.size.width; // 320;
            heightCnt = longSide;
            widthCnt = shortSide;
        }
        else {
            windowHeight = self.view.frame.size.width; // 300...lose 20 for the status bar
            windowWidth = self.view.frame.size.height; // 480 full
            heightCnt = shortSide;
            widthCnt = longSide;
        }
    }
    else {
        if(self.theImage.size.height > self.theImage.size.width) {
            windowHeight = self.view.frame.size.width; //480
            windowWidth =  self.view.frame.size.height; // 300;
            heightCnt = longSide;
            widthCnt = shortSide;
        }
        else {
            windowHeight = self.view.frame.size.height;
            windowWidth = self.view.frame.size.width;
            heightCnt = shortSide;
            widthCnt = longSide;
        }
    }
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {  // just to be safe
        if(widthCnt == 0) widthCnt = 3;
        if(heightCnt == 0) heightCnt = 3;
    }
    else {
        if(widthCnt == 0) widthCnt = 2;
        if(heightCnt == 0) heightCnt = 2;
    }
 
    frame = CGRectMake(0, 0,windowWidth, windowHeight);
    self.passedImage.frame = frame;
    [self.passedImage setImage:self.theImage]; // but not visible cos hidden

    newSize = CGSizeMake(windowWidth, windowHeight);
/*
    // ***                                                                *****
    // *** draw the smiley into whatever frame we have, then recapture it *****
    // ***     this is now done when we save the image!
    // ***                                                                *****
    self.smileyFrame = frame;
    CGSize smileySize = newSize;
    if(windowWidth > windowHeight) {
        CGRect aframe = frame;
        aframe.size.width = aframe.size.height;
        self.smileyFrame = aframe;
        smileySize = CGSizeMake(self.smileyFrame.size.width,self.smileyFrame.size.height);
    }
    UIGraphicsBeginImageContextWithOptions(smileySize,FALSE, 0.0); // creates an image based graphics context
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"winky smiley" ofType:@"png"];
    self.theSmiley = [UIImage  imageWithContentsOfFile:imgPath];
    [self.theSmiley drawInRect:self.smileyFrame];// draw the smiley into a context that is the full window...scales it to fit
    self.theSmiley = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
*/
    /*** now the cheat image ***/
/*
    CGSize falseSize = CGSizeMake(windowWidth/2, windowHeight/2);       // reduce everything so as to reduce datasize
    CGRect falseFrame = CGRectMake(0,0,windowWidth/2,windowHeight/2);    // ditto...its JUST for the cheat view
    UIGraphicsBeginImageContextWithOptions(falseSize,FALSE, 0.0); // creates an image based graphics context
    [self.theImage drawInRect:falseFrame];// draw the full image into a context that is the full false window...scales it to fit
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();     // *** recapture the original image from the image in the frame...
    UIGraphicsEndImageContext();
  */
    /*** now the real images ***/
    _usedWindowHeight = windowHeight;
    _usedWindowWidth = windowWidth;
    UIGraphicsBeginImageContextWithOptions(newSize,FALSE, 0.0); // creates an image based graphics context
    [self.theImage drawInRect:frame];// draw the full image into a context that is the full window...scales it to fit

//    self.theImage = viewImage; // save the cheat view now that theImage has been used
    
    CGPoint thePoints[3];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();

    CGFloat comps[] = {0, 0, 0, 0.15}; // red green blue alpha
    CGColorRef aref =  CGColorCreate(rgb, comps);  // generates a retain count of 1

    CGContextSetStrokeColorWithColor(context, aref);
    CGContextSetLineWidth(context,8);

    thePoints[0] = CGPointMake(4,windowHeight - 8);
    thePoints[1] = CGPointMake(4,4);
    thePoints[2] = CGPointMake(windowWidth,4);
    CGContextAddLines(context,thePoints,3);
    CGContextStrokePath(context);
    CGColorRelease(aref);  // subtle leak without it?

    comps[3] = 0.25;
    aref =  CGColorCreate(rgb, comps);  // generates a retain count of 1
    CGContextSetStrokeColorWithColor(context, aref);
    
    thePoints[0] = CGPointMake(windowWidth - 4,8);
    thePoints[1] = CGPointMake(windowWidth - 4,windowHeight - 4);
    thePoints[2] = CGPointMake(0,windowHeight - 4);
    CGContextAddLines(context,thePoints,3);
    CGContextStrokePath(context);
    
    CGColorRelease(aref);  // subtle leak without it?
    CGColorSpaceRelease(rgb);
    
    tempImage = UIGraphicsGetImageFromCurrentImageContext(); // so now got a new bitmap that is the size of the window
    UIGraphicsEndImageContext();  // end of the main window image
    
    // make frame 1/3 the WINDOW width & ht with an origin at 2/3 down & across so it would be at the pos of the last tile
    tileWidth = windowWidth/widthCnt;
    tileHeight = windowHeight/heightCnt;
    totalCnt = widthCnt * heightCnt;
    
    newSize = CGSizeMake(tileWidth,tileHeight);
    
    _usedTileheight = tileHeight;
    _usedTilewidth = tileWidth;
 
//    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
//    CGFloat comps[] = {1.0, 1.0, 0.0, 1.0}; // red green blue alpha
//    CGColorRef aref =  CGColorCreate(rgb, comps);  // generates a retain count of 1
    
    UIGraphicsBeginImageContextWithOptions(newSize,FALSE, 1.0); // creates an image based graphics context
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetStrokeColorWithColor(context, aref);
//    CGColorRelease(aref);  // subtle leak without it?
    
    virtualOrg_x = virtualOrg_y = drawATx = drawATy = 0.0;
    centre_x = tileWidth/2.0;
    centre_y = tileHeight/2.0;
 
    for (int lc = 0;lc < totalCnt;) {
        
        frame = CGRectMake(virtualOrg_x, virtualOrg_y, tileWidth, tileHeight);
        aView = [[TileView alloc] initWithFrame:frame];
        aView.tag = lc + 1000; // so know what view & make it unique...self.view.tag = 0 which is a value a subview COULD be hence the 1000
        
        // draw only 1/totalCnt orig image will get drawn
        [tempImage drawAtPoint:CGPointMake(drawATx,drawATy) blendMode:kCGBlendModeNormal alpha:1.0];
        
//        frame = CGRectMake(1.0, 1.0, tileWidth - 1, tileHeight - 1);
//        CGContextStrokeRectWithWidth(context, frame, 1);  // draws a rectangle on perimieter of view
        croppedimage = UIGraphicsGetImageFromCurrentImageContext();
        
        aView.tileImage = croppedimage;
        aView.opaque = YES; //default is NO;
        aView.center = CGPointMake(centre_x,centre_y);  // center of the new view
        aView.originalCentre = aView.center;
        if(++lc % widthCnt == 0) {
            centre_x = tileWidth/2.0;
            centre_y += tileHeight;
            virtualOrg_x = drawATx = 0.0;
            virtualOrg_y += tileHeight;
            drawATy -= tileHeight;
        }
        else {
            centre_x += tileWidth;
            virtualOrg_x += tileWidth;
            drawATx -= tileWidth;
        }
/*
        if(lc != 9) {
            CGContextSetRGBFillColor(context, 0.35,0.35,0.35,1.0); // set fill color to gray
            CGContextFillRect(context,frame); // rubs out the current image
        }
*/
        [self.view addSubview:aView];
        [aView release];
    }
    self.viewCount = (int)totalCnt;
    /********************                              ***************/
    /******************** now the 2 'show/hide button' ***************/
    /********************                              ***************/
    tempImage = [UIImage imageNamed:@"71-arrow dn1"];
    frame = CGRectMake(0, 0, tempImage.size.width, tempImage.size.height);
    aView = [[TileView alloc] initWithFrame:frame];
    aView.tag = THE_SHOWHIDE_BTN1; // so know which it is
//    [tempImage drawAtPoint:CGPointMake(windowWidth - frame.size.width, windowHeight - frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
//    croppedimage = UIGraphicsGetImageFromCurrentImageContext();
    aView.tileImage = tempImage; // croppedimage;
    aView.opaque = YES; //default is NO;
    aView.center = CGPointMake(windowWidth - frame.size.width/2.0 - 50, windowHeight - frame.size.height/2.0 - 50);  // center of the button
    aView.originalCentre = aView.center;
    aView.isInPlace = true;
    aView.hidden = true;
    [self.view addSubview:aView];
    [aView release];
    ++self.viewCount;
    tempImage = [UIImage imageNamed:@"71-arrow up1"];
    aView = [[TileView alloc] initWithFrame:frame];
    aView.tag = THE_SHOWHIDE_BTN2; // so know which it is
    aView.tileImage = tempImage; // croppedimage;
    aView.center = CGPointMake(windowWidth - frame.size.width/2.0 - 50, windowHeight - frame.size.height/2.0 - 50);  // center of the button
    aView.originalCentre = aView.center;
    aView.isInPlace = true;
    aView.hidden = true;
    [self.view addSubview:aView];
    [aView release];
    ++self.viewCount;
        /**************************************************/
    
//    CGColorSpaceRelease(rgb);
    UIGraphicsEndImageContext();  // end of generating the images
  
    /************** now to actually jumble them around ****/
    uint8_t carray[64];
    CGPoint a_c;
    SecRandomCopyBytes(kSecRandomDefault, totalCnt, carray);
    if(totalCnt == 1) totalCnt = 2; // will never happen
    for(int lc = 0;lc < totalCnt;lc++) {
        
        aView = (TileView *)[self.view viewWithTag:lc + 1000];
        bview = (TileView *)[self.view viewWithTag:(carray[lc] % (totalCnt - 1)) + 1000];

        a_c = aView.center;
        aView.center = bview.center;
        bview.center = a_c;
    }
    
    for(int lc = 0;lc < totalCnt;lc++) {
        
        aView = (TileView *)[self.view viewWithTag:lc + 1000];
        if(aView.center.x == aView.originalCentre.x && aView.center.y == aView.originalCentre.y) {
            for (int cl = (int)totalCnt - 1; cl >= 0;cl--) {
                bview = (TileView *)[self.view viewWithTag:cl + 1000];
                if(bview.tag == aView.tag)
                    continue;
                a_c = aView.center;
                aView.center = bview.center;
                bview.center = a_c;
                break;
            }
        }
    }

    for(int lc = 0;lc < totalCnt - 1;lc++) {
        
        aView = (TileView *)[self.view viewWithTag:lc + 1000];
        if(aView.center.x == aView.originalCentre.x && aView.center.y == aView.originalCentre.y)
            aView.isInPlace = true;
        }

    if(self.myToolbar.hidden == false) // toolbar visible so show dn arrow
        [self.view bringSubviewToFront:self.myToolbar];
    [self ShowCorrectToolbarIcon];
    // ***                                                                                         ****
    // *** recapture the original image from the image in the frame...saves 1.5MB when we send it  ****
    // *** unfortunately this gets the original jumbled pic...but we rectified the problem above   ****
    /*
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.theImage = viewImage;
     ***/
    /*** save the view as an image in the photo gallery ***

    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    
    also lookup http://blog.codecropper.com/2011/05/getting-metadata-from-images-on-ios/
    http://blog.codecropper.com/2011/05/adding-metadata-to-ios-images-the-easy-way/
    
    - (void)captureStillImageAsynchronouslyFromConnection:(AVCaptureConnection *)connection
completionHandler:(void (^)(CMSampleBufferRef imageDataSampleBuffer, NSError *error))handler
*/
    return;
}
/**************************************************************
 common func to show the right toolbar icon
 if Toolbar visible show dn arrow BTN1
 if Toolbar hidden show up arrow BTN2
 *************************************************************/
-(void) ShowCorrectToolbarIcon {
    int atag1 = THE_SHOWHIDE_BTN1,atag2 = THE_SHOWHIDE_BTN2;
    UIView *aView,*bView;
    
    if(self.myToolbar.hidden)
    {
        atag1 = THE_SHOWHIDE_BTN2;
        atag2 = THE_SHOWHIDE_BTN1;
    }
    
    aView = [self.view viewWithTag:atag1];
    bView = [self.view viewWithTag:atag2];
    aView.hidden = false;
    bView.hidden = true;
    aView.center = bView.center;
    [self.view bringSubviewToFront:aView];
    
    self.the_Visible_ShowHide_Btn_Tag = atag1;
    return;
}
/**************************************************************
 callback for responder when get a long touch
 *************************************************************/
 - (void)theLongPressAction:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Touch the little floating icon to display the toolbar." message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    return;
 }
/**************************************************************
 callback for alert view
 *************************************************************/
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.canQuit) {
        self.canQuit = FALSE;
        if(buttonIndex == 0)
            [self.delegate didFinishWithJumbleView];  // perform any processing..pop the view
    }
    else if(self.askingOrigImage) {
        if(buttonIndex == 1)
            self.wantOrigImage = FALSE;
        self.askingOrigImage = FALSE;
        [self StartTheFileNameTyping];
    }
    return;
}

/**************************************************************
callback for responder when get 1st touch
 ******************************************************/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
    UIView *aview;
    if(self.isTouching && self.touchedView == nil)
        self.isTouching = false;
    if(self.isTouching == false) {

        for (aview in self.view.subviews) {
            if(touch.view == aview) {
                if(touch.view.tag > 990) {   // our helperbutton is at 998 & 999...THE_SHOWHIDE_BTN
                    if((self.passedImage.hidden == false  && (touch.view.tag == self.the_Visible_ShowHide_Btn_Tag || self.peekPicOnTop == false) ) || self.passedImage.hidden == true) {
                        self.isTouching = true;
                        self.touchedView = (TileView *)aview;
                        theTouchPoint = [touch locationInView:self.view];

                        if(touch.view.tag > THE_SHOWHIDE_BTN) {
                            self.touchedView.isSelected = true;
                            [self.view bringSubviewToFront:aview];
                            [self.touchedView setNeedsDisplay];
                            [self animateFirstTouchAtPoint]; 	// Animate the first touch
                        }
                    }
                }
                break;
            }
        }
    }
    return;
}
/**************************************************************
 callback for responder when the touch moves
 ******************************************************/
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	CGPoint location;
    CGPoint tempXY;

    if(touch.view == self.touchedView) {
        if(self.touchedView.isLocked == FALSE) {
            location = [touch locationInView:self.view];
            tempXY = self.touchedView.center;
            tempXY.x += location.x - theTouchPoint.x;
            tempXY.y += location.y - theTouchPoint.y;
            self.touchedView.center = tempXY;
            theTouchPoint = location;
            if(self.touchedView.tag > THE_SHOWHIDE_BTN) {
                UIView *bview  = [self.view viewWithTag:self.the_Visible_ShowHide_Btn_Tag];
                int xPosR = self.touchedView.frame.origin.x + self.touchedView.frame.size.width;
                int yPosR = self.touchedView.frame.origin.y + self.touchedView.frame.size.height;
                int xPosL = self.touchedView.frame.origin.x;
                int yPosL = self.touchedView.frame.origin.y;
                int bxPosL = bview.frame.origin.x;
                int bxPosR = bview.frame.origin.x + bview.frame.size.width;
                int byPosL = bview.frame.origin.y;
                int byPosR = bview.frame.origin.y + bview.frame.size.height;
                if(!(bxPosR < xPosL || bxPosL > xPosR || byPosR < yPosL || byPosL > yPosR))
                    [self.view bringSubviewToFront:bview];
            }
        }
    }
    return;
}
/************************************
 at the end of the touch could do this
 UITouch *touch = [touches anyObject];
 If the touch was in the placardView, bounce it back to the center
 if ([touch view] == placardView) {
 self.userInteractionEnabled = NO; Disable user interaction so subsequent touches don't interfere with animation
 [self animatePlacardViewToCenter];
 return;
 }
 **********************************************/
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    TileView *aview;    
    int i = (int)touch.tapCount;
    if(self.isTouching == FALSE)
        return;
    
    if(touch.view != self.touchedView) // possible??
        return;
    
    if(touch.view.tag < 1000) { // lifted off our control button
        if(touch.view.tag == self.the_Visible_ShowHide_Btn_Tag) {
            if(self.myToolbar.hidden) {
                self.myToolbar.hidden = false;
                [self.view bringSubviewToFront:self.myToolbar];
            }
            else {
                self.myToolbar.hidden = true;
                self.saveBtn.enabled = self.showHiddenTilesBtn.enabled = true; // in case they weren't
                if(self.passedImage.hidden == false && self.peekPicOnTop) // if its at the bot no problem
                    self.passedImage.hidden = true;
            }
            [self ShowCorrectToolbarIcon];
        }
        self.touchedView = nil;
        self.isTouching = false;                
        return;
    }
    
    if(i == 2) // double tap
    {
        [self.view sendSubviewToBack:self.touchedView];
        if(self.passedImage.hidden == false && self.peekPicOnTop == false)
            [self.view sendSubviewToBack:self.passedImage];
    }
    else {
        float sensitiv = 5;
        if(self.snapOnTouchEnded) // snap into position
            sensitiv = self.snapSensitivity;
            
        TileView *tv = self.touchedView;
        CGPoint origCntr = tv.originalCentre;
        CGPoint tempXY = tv.center;
        bool playSound = self.tileSoundON;

        if(abs(tempXY.x - origCntr.x) < sensitiv && abs(tempXY.y - origCntr.y) < sensitiv) {
            if(self.canLock)
                tv.isLocked = true;
            if(tv.isInPlace == true)
                playSound = false;
            tv.center = tv.originalCentre;
            tv.isInPlace = true;
            bool notFinished = FALSE;
            
            for (aview in self.view.subviews) {
                if(aview.tag > 999) {
                    if(aview.isInPlace == FALSE) {
                        notFinished = true;
                        break;
                    }
                }
            }
           
            if(notFinished) {
                if(playSound)
                    AudioServicesPlaySystemSound(_whooshSound);
            }
            else {
                self.puzlDone = true;
                if(self.myToolbar.hidden == true) {
                    self.myToolbar.hidden = false;
                    [self.view bringSubviewToFront:self.myToolbar];
                    [self ShowCorrectToolbarIcon];
                }
                if(self.finishedItOnce == false) {
                    self.finishedItOnce = true;
                    NSString *astr;
                    if(self.finshedPuzlSoundOn) {
                        astr = @"WELL DONE!!";
                        AudioServicesPlaySystemSound(_tadaSound);
                    }
                    else
                        astr = @"PUZZLE FINISHED\nWELL DONE!!";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:astr message:@"" delegate:self
                                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
            }
        }
        else
            tv.isInPlace = self.puzlDone = false;
        if(self.puzlDone == false)
            self.saveBtn.enabled = self.showHiddenTilesBtn.enabled = self.showOrigPicBtn.enabled = true;
        else
            self.saveBtn.enabled = self.showHiddenTilesBtn.enabled = self.showOrigPicBtn.enabled = false;
            
        UIView *bview  = [self.view viewWithTag:self.the_Visible_ShowHide_Btn_Tag];
        int xPosR = self.touchedView.frame.origin.x + self.touchedView.frame.size.width;
        int yPosR = self.touchedView.frame.origin.y + self.touchedView.frame.size.height;
        int xPosL = self.touchedView.frame.origin.x;
        int yPosL = self.touchedView.frame.origin.y;
        int bxPosL = bview.frame.origin.x;
        int bxPosR = bview.frame.origin.x + bview.frame.size.width;
        int byPosL = bview.frame.origin.y;
        int byPosR = bview.frame.origin.y + bview.frame.size.height;
        
        if(self.myToolbar.hidden == false) {
            if(self.myToolbar.frame.origin.y < yPosR)
                [self.view bringSubviewToFront:self.myToolbar];
        }
        if(!(bxPosR < xPosL || bxPosL > xPosR || byPosR < yPosL || byPosL > yPosR))
            [self.view bringSubviewToFront:bview];
    }
    
    self.touchedView.transform = CGAffineTransformIdentity;
    self.touchedView.isSelected = false;
    [self.touchedView setNeedsDisplay];
    self.touchedView = nil;
    self.isTouching = false;
    
    return;
}
/*******************************************
 To impose as little impact on the device as possible, simply set the placard view's center and transformation to the original values.
 *************************************************/
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	self.touchedView.transform = CGAffineTransformIdentity;
    self.touchedView.isSelected = false;
    [self.touchedView setNeedsDisplay];
    self.touchedView = nil;
    return;
}
/************************************************************************
 "Pulse" the view by scaling up then down
 
 This illustrates using UIView's built-in animation.  We want, though, to animate the same property (transform) twice -- first to scale up, then to shrink.  You can't animate the same property more than once using the built-in animation -- the last one wins.  So we'll set a delegate action to be invoked after the first animation has finished.  It will complete the sequence.
 Note that we can pass information -- in this case, the using the context.  The context needs to be a pointer. A convenient way to pass a CGPoint here is to wrap it in an NSValue object.  However, the value returned from valueWithCGPoint is autoreleased.  Normally this wouldn't be an issue because typically if you need to use the value later you store it as an instance variable using an accessor method that retains it, or pass it to another object which retains it.  In this case, though, it's being passed as a void * parameter, and it's not retained by the UIView class.  By the time the delegate method is called, therefore, the autorelease pool will have been popped and the value would no longer be valid.  To address this problem, retain the value here, and release it in the delegate method.
 we could then move the placard to under the finger.
 //	NSValue *touchPointValue = [[NSValue valueWithCGPoint:touchPoint] retain];
 //	[UIView beginAnimations:nil context:touchPointValue];
 ********************************************************************/
- (void)animateFirstTouchAtPoint {
	
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:)];
    self.touchedView.transform =  CGAffineTransformMakeScale(1.2f, 1.2f);
	[UIView commitAnimations];
    return;
}
/***********************************************
 When animations stop we set it to start again
 *************************************************/
- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:MOVE_ANIMATION_DURATION_SECONDS];
    [UIView setAnimationDelegate:self];
	self.touchedView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
	[UIView commitAnimations];
}
/**********************************************************************
 Animation delegate method called when the animation's finished:
 restore the transform and reenable user interaction
 *********************************************************/
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    
	self.touchedView.transform = CGAffineTransformIdentity;
	self.view.userInteractionEnabled = YES;
    return;
}
/********************************************
 show hidden tiles
 ********************************************/
- (void) DoShowTheHiddenTiles {

    bool gotNoHidden = true;
    int lc = 0,uncovered = 0;
    
    if(self.toolBarSoundOn)
        AudioServicesPlaySystemSound(_tickSound);

    for(TileView *aview in self.view.subviews) { // lets get the order right...the ones in front are at the back of the chain!!
        if(aview.tag > THE_SHOWHIDE_BTN) // those below aren't tiles
            aview.tempTag = ++lc;
    }
        
    for (TileView *aview in self.view.subviews) {
        if(aview.tag <= THE_SHOWHIDE_BTN) // those below aren't tiles
            continue;
        if(aview.isInPlace == TRUE) // we only interested in unplaced tiles that may be covered
            continue;
        
        for (TileView *bview in self.view.subviews) {
            if(bview.tag <= THE_SHOWHIDE_BTN) // the tiles are 1000 & up
                continue;
            if(bview.tempTag <= aview.tempTag) // b can't be infront of a nor can it be the same tile
                continue;
            if(bview.isInPlace == true) { // we only interested in placed tiles that could be covering
                
                if(abs(aview.center.x - bview.center.x) > aview.frame.size.width/2 || abs(aview.center.y - bview.center.y) > aview.frame.size.height/2)
                    continue;
                [self.view bringSubviewToFront:aview];  // is close
                gotNoHidden = false;
                ++uncovered;
                break; // just got to be uncovered from 1 tile
            }
        }
    }
    UIAlertView *alert;
    NSString *astr;
    if(self.hiddenTilesMsgOn) {
        if(gotNoHidden || uncovered) {
            if(gotNoHidden)
                astr = @"No tile is hidden by a correctly positioned tile.";
            else if(uncovered) {
                if(uncovered > 1)
                    astr = [NSString stringWithFormat:@"%d tiles were uncovered.",uncovered];
                else
                    astr = @"One tile was uncovered.";
                [self.view bringSubviewToFront:self.myToolbar];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:nil message:astr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    return;
}
/**************************************************************
 menu buttons
 
 quit
 *************************************************************/
-(IBAction)DoQuitButton:(id)sender
{
    self.canQuit = true;
    if(self.toolBarSoundOn)
        AudioServicesPlaySystemSound(_tickSound);
    if(self.quitMsgOn) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Quit this Puzzle?" delegate:self cancelButtonTitle:@"Yes"
                                              otherButtonTitles: @"No",nil];
        
        [alert show];
        [alert release];
    }
    else
        [self.delegate didFinishWithJumbleView];
    return;
}
/*******************************************************************
 help
 **************************************************************/
-(IBAction)DoHelpButton:(id)sender
{
    if(self.toolBarSoundOn)
        AudioServicesPlaySystemSound(_tickSound);
    jumbleHelpViewController *hvc = [[jumbleHelpViewController alloc] initWithNibName:@"jumbleHelpViewController" bundle:nil];
    hvc.delegate = self;

    [self presentViewController:hvc animated:YES completion:NULL]; // have to present it rather than push it cos pushing doesn't work for some reason
//    [self.navigationController pushViewController:hvc animated:YES];  // maybe the view doesn't have an nav controller
    [hvc release];
    return;
}
/****************************************
 finished with help - delegate
*****************************************************/
- (void)didFinishWithJumbleHelpView {
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}
/********************************************
 show hidden tiles
 *********************************************/
-(IBAction)DoShowButton:(id)sender
{
    [self DoShowTheHiddenTiles];
    return;
}
/******************************************
 we are either hiding or showing the original picture
 ***********************************************/
-(IBAction)DoPeekButton:(id)sender
{
    if(self.toolBarSoundOn)
        AudioServicesPlaySystemSound(_tickSound);
    if(self.passedImage.hidden == true) {
        self.passedImage.hidden = false;
        if(self.peekPicOnTop) {
            [self.view bringSubviewToFront:self.passedImage];  // so see the image
            [self.view bringSubviewToFront:self.myToolbar];
            UIView *aview  = [self.view viewWithTag:self.the_Visible_ShowHide_Btn_Tag];
            [self.view bringSubviewToFront:aview];
            self.saveBtn.enabled = self.showHiddenTilesBtn.enabled = false;
        }
        else
            [self.view sendSubviewToBack:self.passedImage];
        if(self.hideOrigPicmsgOn) {
            NSString *astr = @"";
            if(self.haveOriginal)
                astr = @"Touch the curled page icon to hide the original picture and continue with the puzzle";
            else
                astr = @"Touch the curled page icon to continue with the puzzle";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:astr
                                                       delegate:self cancelButtonTitle:@"OK"
                                                       otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }
    else {
        self.passedImage.hidden = true;
        self.saveBtn.enabled = self.showHiddenTilesBtn.enabled = true;
    }

    return;
}
/*********************************************************
 save into a local archive...it may be the recv'd pic that is being saved
 ********************************************************/
-(IBAction)DoSaveButton:(id)sender
{
    [self PerformTheActualSave:false includeOriginal:TRUE];
    return;
}
/******************************************************
 do the actual save....either include or exclude the original image
 *******************************************************/
-(BOOL)PerformTheActualSave:(BOOL)forSending includeOriginal:(BOOL)includeTheOriginal{
    NSString *filePath = @"";
    NSFileManager *fileManager;
    BOOL addExt = TRUE;
    fileManager = [NSFileManager defaultManager];
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/",NSHomeDirectory()];     // thats where we store stuff.
    if(forSending)
        filePath =[filePath stringByAppendingFormat:@"Sent/%@",self.imageNameTxtFld.text];
    else {
        if(self.isRecvdImage || self.isSentImage) {
            if(self.isRecvdImage)
                filePath = [filePath stringByAppendingFormat:@"Received/%@",self.recvdFileName];
            else
                filePath = [filePath stringByAppendingFormat:@"Sent/%@",self.recvdFileName];
            addExt = false;
        }
        else
            filePath = [filePath stringByAppendingString:@"MyzxzxPuzzle"];
    }
    if(addExt)
        filePath =[filePath stringByAppendingString:@".pzlpic"];
   
    NSMutableData *theData = [NSMutableData data];
    NSKeyedArchiver *thearchive = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
    NSInteger theVer = PUZLPIC_VER; // quite important
    [thearchive encodeInt:(int)theVer forKey:@"File Version"];
    [thearchive encodeInt:self.viewCount forKey:@"Total Views"];
    [thearchive encodeInteger:_usedWindowWidth forKey:@"used window width"];
    [thearchive encodeInteger:_usedWindowHeight forKey:@"used window height"];
    
    CGSize aSize = CGSizeMake(_usedTilewidth/2, _usedTileheight/2);       // reduce everything so as to reduce datasize
    CGRect aFrame = CGRectMake(0,0, _usedTilewidth/2, _usedTileheight/2); // ditto...
    UIImage *viewImage;
    int lc = 0;
    for (TileView *aview in self.view.subviews) {
        if(aview.tag > 900) {
            UIGraphicsBeginImageContextWithOptions(aSize,FALSE, 0.0); // creates an image based graphics context
            [aview.tileImage drawInRect:aFrame];// draw the full image of the tile into a space 1/4 the size...scales it to fit
            viewImage = UIGraphicsGetImageFromCurrentImageContext();     // *** recapture the original image from the image in the frame...
            UIGraphicsEndImageContext();
            ++lc;
            if(aview.tag == THE_SHOWHIDE_BTN1 || aview.tag == THE_SHOWHIDE_BTN2)
                [thearchive encodeObject:aview.tileImage forKey:[NSString stringWithFormat:@"tagged view image %d",lc]];
            else
                [thearchive encodeObject:viewImage forKey:[NSString stringWithFormat:@"tagged view image %d",lc]];
            [thearchive encodeBool:aview.isLocked forKey:[NSString stringWithFormat:@"tagged view islocked %d",lc]];
            [thearchive encodeBool:aview.isInPlace forKey:[NSString stringWithFormat:@"tagged view isinplace %d",lc]];
            [thearchive encodeCGRect:aview.frame forKey:[NSString stringWithFormat:@"tagged view frame %d",lc]];
            [thearchive encodeCGPoint:aview.originalCentre forKey:[NSString stringWithFormat:@"tagged view orig centre %d",lc]];
            [thearchive encodeCGPoint:aview.center forKey:[NSString stringWithFormat:@"tagged view centre %d",lc]];
            [thearchive encodeInt:(int)aview.tag forKey:[NSString stringWithFormat:@"tagged view tag %d",lc]];
        }
    }
    
    if(self.toolBarSoundOn)  // place here
        AudioServicesPlaySystemSound(_tickSound);
    
    BOOL gotOriginal = self.haveOriginal;
    if(includeTheOriginal) {  // the 'original' may even be the smiley if its a recv'd file..keep like this in case we decide to let users have different smileys
        aSize = CGSizeMake(_usedWindowWidth/4,_usedWindowHeight/4);
        aFrame = CGRectMake(0,0,_usedWindowWidth/4,_usedWindowHeight/4);
        UIGraphicsBeginImageContextWithOptions(aSize,FALSE, 0.0); // creates an image based graphics context
        [self.theImage drawInRect:aFrame];// draw the full image of the tile into a space 1/4 the size...scales it to fit
        viewImage = UIGraphicsGetImageFromCurrentImageContext();     // *** recapture the original image from the image in the frame...
        UIGraphicsEndImageContext();
        [thearchive encodeObject:viewImage forKey:@"passed image image"];
//        [thearchive encodeObject:self.theImage forKey:@"passed image image"];
        [thearchive encodeCGRect:self.passedImage.frame forKey:@"passed image frame"];
    }
    else {
        /*** create a smiley based on the original pic ***/
        /***                                                                *****/
        /*** draw the smiley into whatever frame we have, then recapture it *****/
        /***                                                                *****/
        CGRect aframe;
        aframe = self.smileyFrame = self.passedImage.frame;
        CGSize smileySize = self.smileyFrame.size;
        if(smileySize.width > smileySize.height) {
            aframe.size.width = aframe.size.height;  // make it a square
            self.smileyFrame = aframe;
        }
        aframe.size.width /= 4;  //now reduce by 1/16th
        aframe.size.height /=4;
        smileySize = CGSizeMake(aframe.size.width,aframe.size.height);
        UIGraphicsBeginImageContextWithOptions(smileySize,FALSE, 0.0); // creates an image based graphics context
        NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"winky smiley" ofType:@"png"];
        self.theSmiley = [UIImage  imageWithContentsOfFile:imgPath];
        [self.theSmiley drawInRect:aframe];// draw the smiley into a context that is the full window...scales it to fit
        self.theSmiley = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        [thearchive encodeObject:self.theSmiley forKey:@"passed image image"];
        [thearchive encodeCGRect:self.smileyFrame forKey:@"passed image frame"]; // this is the actual smiley frame
        gotOriginal = false;
    }
    [thearchive encodeBool:gotOriginal forKey:@"got original"];
    [thearchive finishEncoding];
    
    // create file ALWAYS creates a file (recreates if it existed)...academic if it existed
    // we then dump the stuff to the file
    if([fileManager createFileAtPath:filePath contents:theData attributes:Nil] == FALSE) {
        [self MyAlertWithError:@"FILE ERROR" theMessage:@"Cannot Recreate Data File.\nPlease inform Support"]; // and now??
        [thearchive release];
        return false;
    }
    
    [thearchive release];
    if(forSending)
        return true;
    if(self.saveMsgOn) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Puzzle Saved" delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    return true;
}
/******************************************************
 setup image from a archive
 not called anywhere!!
 *******************************************************/
-(void)DoTheImageRestore
{
    NSString *filePath = @"";
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/MyzxzxPuzzle.pzlpic",NSHomeDirectory()];
    
    NSMutableData *theData = [NSMutableData dataWithContentsOfFile:filePath];
    NSKeyedUnarchiver *theunarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
    
    UIImage *animage;
    animage = [theunarchive decodeObjectForKey:@"passed image image"];
    self.theImage = animage;
    [theunarchive finishDecoding];
    [theunarchive release];
    
    return;
}
/****************************************************************
 restore from an archive
 ****************************************************************/
-(void)DoTheWholeRestore:(NSString *)filePath
{
    
    if([self.view.subviews count]) {
        for (UIView *aview in self.view.subviews) {
            if(aview.tag > 900) // remove all the views we programmatically add
                [aview removeFromSuperview];
        }
    }
/*
    NSString *filePath = @"";
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/Views.pzlpic",NSHomeDirectory()];
*/
    NSMutableData *theData = [NSMutableData dataWithContentsOfFile:filePath];
    NSKeyedUnarchiver *theunarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
    TileView *aview;
    UIImage *animage;
    int aval,atag;
    CGRect aframe,bframe;
    CGSize asize;
    CGPoint apoint;
    NSInteger recvdWindowWidth,recvdWindowHeight;
    float theWfactor,theHfactor,theXfactor,theYfactor;
    BOOL localLandscape;
    
    aval = [theunarchive decodeIntForKey:@"File Version"]; // don't need it yet....
    aval = aval;
    
    recvdWindowWidth = [theunarchive decodeIntegerForKey:@"used window width"];
    recvdWindowHeight = [theunarchive decodeIntegerForKey:@"used window height"];
    if(recvdWindowWidth == 0) {
        aframe = [theunarchive decodeCGRectForKey:@"passed image frame"];
        recvdWindowWidth = aframe.size.width;
        recvdWindowHeight = aframe.size.height;
    }
    if(self.view.frame.size.width > self.view.frame.size.height)
        localLandscape = true;
    else
        localLandscape = false;
    if((recvdWindowWidth > recvdWindowHeight && localLandscape) || (recvdWindowWidth < recvdWindowHeight && !localLandscape)) {  // both same orientation
        theWfactor = (float)self.view.frame.size.width/(float)recvdWindowWidth;
        theHfactor = (float)self.view.frame.size.height/(float)recvdWindowHeight;
    }
    else {
        theWfactor = (float)self.view.frame.size.height/(float)recvdWindowWidth;
        theHfactor = (float)self.view.frame.size.width/(float)recvdWindowHeight;
    }
    if(recvdWindowWidth > recvdWindowHeight) {
        theXfactor = theWfactor;
        theYfactor = theHfactor;
    }
    else {
        theXfactor = theWfactor;
        theYfactor = theHfactor;
    }
    aval = [theunarchive decodeIntForKey:@"Total Views"];
    self.viewCount = aval;
    for (int cl = 0,lc = 1;cl < self.viewCount;cl++,lc++) {
        aframe = [theunarchive decodeCGRectForKey:[NSString stringWithFormat:@"tagged view frame %d",lc]];
        animage = [theunarchive decodeObjectForKey:[NSString stringWithFormat:@"tagged view image %d",lc]];
        atag = [theunarchive decodeIntForKey:[NSString stringWithFormat:@"tagged view tag %d",lc]];
        if(atag != THE_SHOWHIDE_BTN1 && atag != THE_SHOWHIDE_BTN2) {
            aframe.size.width *= theWfactor;
            aframe.size.height *= theHfactor;
            asize = CGSizeMake(aframe.size.width,aframe.size.height);
            bframe = CGRectMake(0,0,asize.width,asize.height);
            UIGraphicsBeginImageContextWithOptions(asize,FALSE, 0.0); // creates an image based graphics context
            [animage drawInRect:bframe];                              // draw the full image of the tile into the frame...scales it to fit
            animage = UIGraphicsGetImageFromCurrentImageContext();     // recapture the original image from the image in the frame...
            UIGraphicsEndImageContext();
            _usedTilewidth = aframe.size.width;
            _usedTileheight = aframe.size.height;
        }
        aview = [[TileView alloc] initWithFrame:aframe];
        aview.tileImage = animage;
        aview.tag = atag;
        aview.isLocked = [theunarchive decodeBoolForKey:[NSString stringWithFormat:@"tagged view islocked %d",lc]];
        aview.isInPlace = [theunarchive decodeBoolForKey:[NSString stringWithFormat:@"tagged view isinplace %d",lc]];
        apoint = [theunarchive decodeCGPointForKey:[NSString stringWithFormat:@"tagged view orig centre %d",lc]];
        apoint.x *= theXfactor;
        apoint.y *= theYfactor;
        aview.originalCentre = apoint;
        apoint = [theunarchive decodeCGPointForKey:[NSString stringWithFormat:@"tagged view centre %d",lc]];
        apoint.x *= theXfactor;
        apoint.y *= theYfactor;
        aview.center = apoint;
        aview.opaque = YES; //default is NO;
        [aview setNeedsDisplay];
        [self.view addSubview:aview];
        [aview release];
    }
    
    self.finishedItOnce = self.canQuit = self.puzlDone = false;
    self.isTouching = false;
    self.myToolbar.hidden = self.passedImage.hidden = self.showHiddenTilesBtn.enabled = true;

    [self GetAllTheSettings];
    if(self.initialShowToolbar) {
        [self.view bringSubviewToFront:self.myToolbar];
    }
    
    [self ShowCorrectToolbarIcon];
    
    aframe = [theunarchive decodeCGRectForKey:@"passed image frame"];
    aframe.size.width *= theWfactor;
    aframe.size.height *= theHfactor;
    _usedWindowHeight = recvdWindowHeight * theHfactor;
    _usedWindowWidth = recvdWindowWidth * theWfactor;
    self.passedImage.frame = aframe;
    [self.passedImage setImage:self.theImage];
    self.passedImage.hidden = true;
    
    self.haveOriginal = [theunarchive decodeBoolForKey:@"got original"];
    
    [theunarchive finishDecoding];
    [theunarchive release];
    
    return;
}
/*------------------------------------------------
 display an error screen
 the message returned by NSERROR is not adequate to describe the problem
 NSString *message = [NSString stringWithFormat:@"Error! %@ %@",[theError localizedDescription],[theError localizedFailureReason]];
 -------------------------------------------------*/
- (void)MyAlertWithError:(NSString *)theTitle theMessage:(NSString *)theError {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:theTitle
													message:theError
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
    
    return;
}
/*------------------------------------------------
 the whole sending bit
 -------------------------------------------------*/
- (IBAction)DoForwardPic:(id)sender {
    
    self.wantOrigImage = true;  // we may allow users to have different smileys so if the image is from another user we want to keep the 'original' regardless if its a smiley itself.
    if(self.haveOriginal) { // but only ask if we actually have an original image with the puzzle
        self.askingOrigImage = self.wantOrigImage = true;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Include the\nOriginal Image?" delegate:self
                                                  cancelButtonTitle:@"Yes" otherButtonTitles:@"No",nil];
        [alert show];
        [alert release];
    }
    else
        [self StartTheFileNameTyping];
    
//    [self DoEmailMessaging];  call it in the alert handler
    /**** because SMS doesn't send the attachment, & whatsApp can't send the attachment, go stright to mail ***
    UIActionSheet *theMessagingOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Mail",@"SMS",nil];
	theMessagingOptions.actionSheetStyle = UIActionSheetStyleDefault;
	[theMessagingOptions showInView:self.view];
*/
    return;
}
/*******************
 the action sheet not being used cos sms & whatsapp don't work
 *********************/
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the sheets buttons
	switch(buttonIndex) {
        case 0:
            [self DoEmailMessaging];
            break;
        case 1:
            [self DoSmsMessaging];
            break;
        default:  // cancel
            break;
    }
    return;
}
//-------------------------------------------------------
//
//    requirements for emailing
//
//-------------------------------------------------------
-(void) DoEmailMessaging {
    
    
    if([self PerformTheActualSave:true includeOriginal:self.wantOrigImage] == false)
        return;
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:self.imageNameTxtFld.text] ; //]@"puzlPic Puzzle"];
    
    //--- Set up the recipients ---
//    NSArray *toRecipients = [NSArray arrayWithObjects:@"default_email_receipient@gmail.com",nil];
    //      NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com",@"third@example.com", nil];
    //    NSArray *bccRecipients = [NSArray arrayWithObjects:@"four@example.com",nil];
    
//    [picker setToRecipients:toRecipients];
    //    [picker setCcRecipients:ccRecipients];
    //    [picker setBccRecipients:bccRecipients];
    
    //---- Attach the image to the email ----
    NSString *filePath = @"";
    NSString *fname = @"";
    fname = [fname stringByAppendingFormat:@"%@.pzlpic",self.imageNameTxtFld.text];
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/Sent/%@",NSHomeDirectory(),fname];
    
    NSData *theData = [NSData dataWithContentsOfFile:filePath];
   
//   [picker addAttachmentData:theData mimeType:@"image/com.pzlpic.pic" fileName:@"myPicPuzl"];
   [picker addAttachmentData:theData mimeType:@"example/pzlpic" fileName:fname];
    
    //------ Fill out the email body text ----------
    NSString *emailBody = @"";
    emailBody = [emailBody stringByAppendingString:@"Hi\nI challenge you to solve my picture puzzle."];
    //    emailBody = [emailBody stringByAppendingFormat:@"Contact#:%@\n",_contactNumTxtFld.text];
    emailBody = [emailBody stringByAppendingString:@"\n\n\nThe attached puzzle was created by puzlPic v2.1\n\nAnd, if you don't have a copy, just download it from the Apple AppStore.\nSimply search for \"PuzlPic\" (but you can only send puzzles from the full version)."];
    [picker setMessageBody:emailBody isHTML:NO];
    
    // Present the mail composition interface.
    [self presentViewController:picker animated:YES completion:NULL];
    return;
}
//-------------------------------------------------------------------------
//
// The mail compose view controller delegate method
//
//--------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
//----------------------------------------------------------------------------
//
// requirements for SMSing
//
// Check that the current device can send SMS messages before
// creating an instance of MFMessageComposeViewController.  If the
// device can not send SMS messages, [[MFMessageComposeViewController alloc] init] will return nil.  The app
// will crash when it calls -presentViewController:animated:completion: with a nil view controller.
//
// Displays an SMS composition interface inside the application.
//----------------------------------------------------------------------------
-(void) DoSmsMessaging {
    
    if (![MFMessageComposeViewController canSendText]) {  // The device can not send SMS
        [self MyAlertWithError:@"SMS ERROR" theMessage:@"This device is not configured\nfor sending SMS.\nThe Operation has now been Cancelled."];
        return;
    }
    if(![MFMessageComposeViewController canSendAttachments]) { // we can't send attachments
        [self MyAlertWithError:@"SMS ERROR" theMessage:@"This device is not configured\nfor sending SMS attachments.\nYou will need to use the mail option.\nThe Operation has now been Cancelled."];
        return;
    }
    
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    
    // Specify one or more preconfigured recipients.  The user has
    // the option to remove or add recipients from the message composer view
    // controller.
    picker.recipients = @[@"Phone number here"];
    
    // specify the initial message text that will appear in the message
    // composer view controller.
    
    picker.body = @"Hi <friend>\nI challenge you to see what this puzzle is!";
    picker.body = [picker.body stringByAppendingString:@"\n\nGenerated by puzlPic v2.1."];
    
    //---- Attach the image to the sms ----
    NSString *filePath = @"";
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/MyzxzxPuzzle.pzlpic",NSHomeDirectory()];
    
    if(![MFMessageComposeViewController isSupportedAttachmentUTI:@"com.SolveitByDesign.pzlpic"]) {
        [self MyAlertWithError:@"SMS ERROR" theMessage:@"This device is not configured\nfor sending puzlPIC attachments.\nYou will need to use the mail option.\nThe Operation has now been Cancelled."];
        return;
    }
    NSData *theData = [NSData dataWithContentsOfFile:filePath];
    if(![picker addAttachmentData:theData typeIdentifier:@"com.SolveitByDesign.pzlpic" filename:@"myPicPuzl.pzlpic"]) {
//    NSURL *anurl = [NSURL fileURLWithPath:filePath];
//    if(![picker addAttachmentURL:anurl withAlternateFilename:@"myPicPuzl.pzlpic"]) {
        [self MyAlertWithError:@"ATTACH ERROR" theMessage:@"Can't attach the file"];
        return;
    }
    [self presentViewController:picker animated:YES completion:NULL];
    return;
}
// -------------------------------------------------------------------------------
//	messageComposeViewController:didFinishWithResult:
//  Dismisses the message composition interface when users tap Cancel or Send.
//  Proceeds to update the feedback message field with the result of the
//  operation.
// -------------------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	// Notifies users about errors associated with the interface
	[self dismissViewControllerAnimated:YES completion:NULL];
	switch (result)
	{
		case MessageComposeResultCancelled:
            [self MyAlertWithError:@"SMS Alert" theMessage:@"Result: SMS sending canceled"];
			break;
		case MessageComposeResultSent:
            [self MyAlertWithError:@"" theMessage:@"Result: SMS sent"];
			break;
		case MessageComposeResultFailed:
            [self MyAlertWithError:@"SMS error" theMessage:@"Result: SMS sending failed"];
			break;
		default:
            [self MyAlertWithError:@"Unknown SMS Problem" theMessage:@"Result: SMS not sent"];
			break;
	}
    return;
}

/*
 <array>
 <dict>
 <key>UTTypeConformsTo</key>
 <array>
 <string>com.solveit.pzlpic</string>
 </array>
 <key>UTTypeDescription</key>
 <string>puzlpic data</string>
 <key>UTTypeIdentifier</key>
 <string>com.solveit.pzlpic</string>
 <key>UTTypeTagSpecification</key>
 <dict>
 <key>public.filename-extension</key>
 <string>pzlpic</string>
 <key>public.mime-type</key>
 <string>example/pzlpic</string>
 </dict>
 </dict>
 </array>

 */

// -------------------------------------------------------------------------------
//	editing for the image file name
// -------------------------------------------------------------------------------
- (void)StartTheFileNameTyping {
    self.imageNameLbl.hidden = self.imageNameTxtFld.hidden = false;
    [self.view bringSubviewToFront:self.imageNameLbl];
    [self.view bringSubviewToFront:self.imageNameTxtFld];
    self.theToolBar.hidden = true;
    self.imageNameTxtFld.text = @"MySentPuzzle";
    [self.imageNameTxtFld becomeFirstResponder];
    return;
}
//-----------------------------------------
// sequence of events when user touches
//
// 1) another textfield...              2) the return key
// shouldBegin touched field                shouldReturn current field
// shouldEnd   current field                shouldEnd    current field
// didEnd      current field                didEnd       current field
// didBegin    touched field
//
//
// only test if all ok just before saving
//
- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField {
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; // this calls textFieldShouldEndEditing & keyboard disappears if it returns YES
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if([textField.text length] != 0) {
        self.imageNameTxtFld.hidden = self.imageNameLbl.hidden = true;
        self.theToolBar.hidden = false;
        [self DoEmailMessaging];
        return YES;
    }
    textField.text = @"MySentPuzzle";
    return NO;
}
@end
