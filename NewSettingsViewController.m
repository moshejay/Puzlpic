//
//  NewSettingsViewController.m
//  PuzlPic
//
//  Created by moshe jacobson on 5/04/13.
//
//

#import "NewSettingsViewController.h"

@interface NewSettingsViewController ()

@property (nonatomic, retain) IBOutlet UILabel *shortCount,*longCount;
@property (nonatomic, retain) IBOutlet UISlider *shortCountSlider,*longCountSlider,*snapSensitivitySlider;
@property (nonatomic, retain) IBOutlet UISwitch *locTileYesNo,*snapOnTouchEndedYesNo,*soundOnOffYesNo,*touchMsgOnOff;

@property (assign) NSInteger currentLongSide, currentShortSide,currentSnapSensitivity;
@property (assign) BOOL lockTile,snapOnTouchEnded,soundOn,touchMsgOn;

-(IBAction)shortCountSliderA:(id)sender;
-(IBAction)longCountSliderA:(id)sender;
-(IBAction)locTileSwCntrlA:(id)sender;
-(IBAction)snapTileSwCntrlA:(id)sender;
-(IBAction)snapSensitivitySliderA:(id)sender;
-(IBAction)soundSwCntrl:(id)sender;
-(IBAction)touchMsgSwCntrl:(id)sender;

-(void)SaveSettings;


@end

@implementation NewSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Configure the select button on the navigator bar...the cancel is done automatically if we do nothing.
        // initWithBarButtonSystemItem:uib UIBarButtonSystemItemAction target:self action:@selector(ActionProd)];
//        UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(SaveSettings)];
//        self.navigationItem.rightBarButtonItem = selectButton;
//        [selectButton release];

    }
    return self;
}

-(void)dealloc {
    [_shortCount release];
    [_longCount release];
    [_shortCountSlider release];
    [_longCountSlider release];
    [_locTileYesNo release];
    [_snapOnTouchEndedYesNo release];
    [_soundOnOffYesNo release];
    [_snapSensitivitySlider release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.navigationItem.title = @"PuzlPic Settings";
    self.navigationItem.hidesBackButton = false;
    self.navigationItem.rightBarButtonItem.enabled = false;

    // Do any additional setup after loading the view from its nib.
    self.currentLongSide = self.currentShortSide = 3;
    self.currentSnapSensitivity = 40;
    NSInteger aval;

    aval = [[NSUserDefaults standardUserDefaults] integerForKey:@"PuzlPicLongSide"];
    if(aval != 0)
        self.currentLongSide = aval;
    self.longCountSlider.value = self.currentLongSide;
    self.longCount.text = [NSString stringWithFormat:@"(%d)",(int)self.currentLongSide];

    aval = [[NSUserDefaults standardUserDefaults] integerForKey:@"PuzlPicShortSide"];
    if(aval != 0)
        self.currentShortSide = aval;
    self.shortCountSlider.value = self.currentShortSide;
    self.shortCount.text = [NSString stringWithFormat:@"(%d)",(int)self.currentShortSide];

    aval = [[NSUserDefaults standardUserDefaults] integerForKey:@"PuzlPicSnapSensitivity"];
    if(aval != 0)
        self.currentSnapSensitivity = aval;
    self.snapSensitivitySlider.value = self.currentSnapSensitivity;
    
    self.lockTile = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicLockTile"];
    self.locTileYesNo.thumbTintColor = [UIColor greenColor];
    if(self.lockTile)
        [self.locTileYesNo setOn:YES animated:FALSE];

    self.snapOnTouchEnded = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicSnapTile"] ^ 1; // converse
    self.snapOnTouchEndedYesNo.thumbTintColor = [UIColor greenColor];
    if(self.snapOnTouchEnded)
        [self.snapOnTouchEndedYesNo setOn:YES animated:FALSE];

    self.soundOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicSoundOff"] ^ 1;
    self.soundOnOffYesNo.thumbTintColor = [UIColor greenColor];
    if(self.soundOnOffYesNo)
        [self.soundOnOffYesNo setOn:YES animated:FALSE];

    self.touchMsgOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicTouchMsgOff"] ^ 1;
    self.touchMsgOnOff.thumbTintColor = [UIColor greenColor];
    if(self.touchMsgOn)
        [self.touchMsgOnOff setOn:YES animated:FALSE];
    
    return;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    return;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated {
    [self SaveSettings];
    [super viewWillDisappear:animated];
}
/********************************
 < 6.0
 doesn't seem to be called in ios6.0+ but anyway want it to remain in portrait
 *************************************/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if(interfaceOrientation == UIInterfaceOrientationPortrait)
        return YES;
    return NO;
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
    
    return UIInterfaceOrientationPortrait;
}

/*******************************************
 save the user settings
 *************************************/
-(void)SaveSettings {
    
    if(self.currentLongSide == 1 && self.currentShortSide == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Invalid Combination.\nBoth sides may NOT be 1!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
        
    }
    self.soundOn ^= 1; //its the converse
    self.snapOnTouchEnded ^=1; //its the converse
    self.touchMsgOn ^= 1; //its the converse because may not exist
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentLongSide forKey:@"PuzlPicLongSide"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentShortSide forKey:@"PuzlPicShortSide"];
    [[NSUserDefaults standardUserDefaults] setBool:self.lockTile forKey:@"PuzlPicLockTile"];
    [[NSUserDefaults standardUserDefaults] setBool:self.snapOnTouchEnded forKey:@"PuzlPicSnapTile"];
    [[NSUserDefaults standardUserDefaults] setBool:self.soundOn forKey:@"PuzlPicSoundOff"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentSnapSensitivity forKey:@"PuzlPicSnapSensitivity"];
    [[NSUserDefaults standardUserDefaults] setBool:self.touchMsgOn forKey:@"PuzlPicTouchMsgOff"];
    
    return;
}
/**************************************************************
 callback for alert view
 *************************************************************/
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    return;
}

/********************************************
 callback for short slider
 *******************************************/
-(IBAction)shortCountSliderA:(id)sender {

    int aval = self.shortCountSlider.value;
    self.shortCount.text = [NSString stringWithFormat:@"(%d)",aval];
    self.currentShortSide = aval;
    return;
}
/********************************************
  callback for long slider
  *******************************************/
-(IBAction)longCountSliderA:(id)sender {
    int aval = self.longCountSlider.value;
    self.longCount.text = [NSString stringWithFormat:@"(%d)",aval];
    self.currentLongSide = aval;
    return;
}
/********************************************
 callback for switch
 *******************************************/
-(IBAction)locTileSwCntrlA:(id)sender {
    self.lockTile = self.locTileYesNo.on;
    return;
}
/********************************************
 callback for switch
 *******************************************/
-(IBAction)snapTileSwCntrlA:(id)sender {
    self.snapOnTouchEnded = self.snapOnTouchEndedYesNo.on;
    return;
}
/********************************************
 callback for sound switch
 *******************************************/
-(IBAction)soundSwCntrl:(id)sender {
    self.soundOn = self.soundOnOffYesNo.on;
    return;
}
/********************************************
 callback for sensitivity slider
 *******************************************/
-(IBAction)snapSensitivitySliderA:(id)sender {
    int aval = self.snapSensitivitySlider.value;
//    self.snapSensitivitySlider.text = [NSString stringWithFormat:@"(%d)",aval];
    self.currentSnapSensitivity = aval;
    return;
}
/********************************************
 callback for touch message
 *******************************************/
-(IBAction)touchMsgSwCntrl:(id)sender {
    self.touchMsgOn = self.touchMsgOnOff.on;
    return;
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
