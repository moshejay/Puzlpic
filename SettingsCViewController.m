//
//  SettingsCViewController.m
//  PuzlPic
//
//  Created by moshe jacobson on 9/04/13.
//
//

#import "SettingsCViewController.h"

@interface SettingsCViewController ()

@property (nonatomic, retain) IBOutlet UISwitch *soundOnOffYesNo,*touchMsgOnOff,*puzlToolbarOnOff;
@property (assign) BOOL soundOn,touchMsgOn,puzlToolBarOn;

-(IBAction)soundSwCntrl:(id)sender;
-(IBAction)touchMsgSwCntrl:(id)sender;
-(IBAction)touchPuzlToolbarSwCntrl:(id)sender;

-(void)SaveSettings;

@end

@implementation SettingsCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc {
    [_soundOnOffYesNo release];
    [_touchMsgOnOff release];
    [_puzlToolbarOnOff release];
    [super dealloc];
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
    self.navigationItem.title = @"System";
    self.navigationItem.hidesBackButton = false;
    self.navigationItem.rightBarButtonItem.enabled = false;
//   UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(SaveSettings)];
    //    self.navigationItem.rightBarButtonItem = selectButton;

    
    // Do any additional setup after loading the view from its nib.
    
    self.soundOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicSoundOff"] ^ 1;
    if(canTint)
        self.soundOnOffYesNo.thumbTintColor = [UIColor greenColor];
    if(self.soundOn)
        [self.soundOnOffYesNo setOn:YES animated:FALSE];
    
    self.touchMsgOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicTouchMsgOff"] ^ 1;
    if(canTint)
        self.touchMsgOnOff.thumbTintColor = [UIColor greenColor];
    if(self.touchMsgOn)
        [self.touchMsgOnOff setOn:YES animated:FALSE];
 
    self.puzlToolBarOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicPuzlToolbarOff"] ^ 1;
    if(canTint)
        self.puzlToolbarOnOff.thumbTintColor = [UIColor greenColor];
    if(self.puzlToolBarOn)
        [self.puzlToolbarOnOff setOn:YES animated:FALSE];
    
    return;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self SaveSettings];
    [super viewWillDisappear:animated];
}

/*******************************************
 save the user settings
 *************************************/
-(void)SaveSettings {
    
    self.soundOn ^= 1; //its the converse
    self.touchMsgOn ^= 1; //its the converse because may not exist
    self.puzlToolBarOn ^=1 ; //its the converse because may not exist
    [[NSUserDefaults standardUserDefaults] setBool:self.soundOn forKey:@"PuzlPicSoundOff"];
    [[NSUserDefaults standardUserDefaults] setBool:self.touchMsgOn forKey:@"PuzlPicTouchMsgOff"];
    [[NSUserDefaults standardUserDefaults] setBool:self.puzlToolBarOn forKey:@"PuzlPicPuzlToolbarOff"];
    
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
 callback for touch message
 *******************************************/
-(IBAction)touchMsgSwCntrl:(id)sender {
    self.touchMsgOn = self.touchMsgOnOff.on;
    return;
}

/********************************************
 callback for toolbar message
 *******************************************/
-(IBAction)touchPuzlToolbarSwCntrl:(id)sender {
    self.puzlToolBarOn = self.puzlToolbarOnOff.on;
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
