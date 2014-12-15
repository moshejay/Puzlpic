//
//  SettingsAViewController.m
//  PuzlPic
//
//  Created by moshe jacobson on 9/04/13.
//
//

#import "SettingsAViewController.h"

@interface SettingsAViewController ()
@property (nonatomic, retain) IBOutlet UILabel *shortCount,*longCount;
@property (nonatomic, retain) IBOutlet UISlider *shortCountSlider,*longCountSlider;

@property (assign) NSInteger currentLongSide, currentShortSide;

-(IBAction)shortCountSliderA:(id)sender;
-(IBAction)longCountSliderA:(id)sender;

-(void)SaveSettings;

@end

@implementation SettingsAViewController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Tile Counts";
    self.navigationItem.hidesBackButton = false;
    self.navigationItem.rightBarButtonItem.enabled = false;
     
    // Do any additional setup after loading the view from its nib.
    self.currentLongSide = self.currentShortSide = 2;

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

-(void)dealloc {
[_shortCount release];
[_longCount release];
[_shortCountSlider release];
[_longCountSlider release];
    [super dealloc];
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
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentLongSide forKey:@"PuzlPicLongSide"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentShortSide forKey:@"PuzlPicShortSide"];
    
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

@end
