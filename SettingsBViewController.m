//
//  SettingsBViewController.m
//  PuzlPic
//
//  Created by moshe jacobson on 9/04/13.
//
//

#import "SettingsBViewController.h"

@interface SettingsBViewController ()

@property (nonatomic, retain) IBOutlet UISlider *snapSensitivitySlider;
@property (nonatomic, retain) IBOutlet UISwitch *locTileYesNo,*snapOnTouchEndedYesNo;

@property (assign) NSInteger currentSnapSensitivity;
@property (assign) BOOL lockTile,snapOnTouchEnded;

-(IBAction)locTileSwCntrlA:(id)sender;
-(IBAction)snapTileSwCntrlA:(id)sender;
-(IBAction)snapSensitivitySliderA:(id)sender;

-(void)SaveSettings;


@end

@implementation SettingsBViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL canTint = true;
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedAscending)
        canTint = false;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Lock and Snap";
    self.navigationItem.hidesBackButton = false;
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    // Do any additional setup after loading the view from its nib.
    self.currentSnapSensitivity = 40;
    NSInteger aval;
    
    aval = [[NSUserDefaults standardUserDefaults] integerForKey:@"PuzlPicSnapSensitivity"];
    if(aval != 0)
        self.currentSnapSensitivity = aval;
    self.snapSensitivitySlider.value = self.currentSnapSensitivity;
    
    self.lockTile = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicLockTile"];
    
    if(canTint)
        self.locTileYesNo.thumbTintColor = [UIColor redColor];
    if(self.lockTile)
        [self.locTileYesNo setOn:YES animated:FALSE];
    
    self.snapOnTouchEnded = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicSnapTile"] ^ 1; // converse
    if(canTint)
        self.snapOnTouchEndedYesNo.thumbTintColor = [UIColor redColor];
    if(self.snapOnTouchEnded)
        [self.snapOnTouchEndedYesNo setOn:YES animated:FALSE];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self SaveSettings];
    [super viewWillDisappear:animated];
}

/*******************************************
 save the user settings
 *************************************/
-(void)SaveSettings {
    
    self.snapOnTouchEnded ^=1; //its the converse
    [[NSUserDefaults standardUserDefaults] setBool:self.lockTile forKey:@"PuzlPicLockTile"];
    [[NSUserDefaults standardUserDefaults] setBool:self.snapOnTouchEnded forKey:@"PuzlPicSnapTile"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentSnapSensitivity forKey:@"PuzlPicSnapSensitivity"];
    
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
 callback for sensitivity slider
 *******************************************/
-(IBAction)snapSensitivitySliderA:(id)sender {
    int aval = self.snapSensitivitySlider.value;
    //    self.snapSensitivitySlider.text = [NSString stringWithFormat:@"(%d)",aval];
    self.currentSnapSensitivity = aval;
    return;
}

-(void)dealloc {
    [_locTileYesNo release];
    [_snapOnTouchEndedYesNo release];
    [_snapSensitivitySlider release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
