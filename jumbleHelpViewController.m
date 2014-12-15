//
//  jumbleHelpViewController.m
//  PuzlPic
//
//  Created by moshe jacobson on 21/04/13.
//
//

#import "jumbleHelpViewController.h"
#include "HelpViewController.h"

@interface jumbleHelpViewController ()
-(IBAction)DoQuitButton:(id)sender;

@end

@implementation jumbleHelpViewController

@synthesize delegate;

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
//***** view was not pushed on by a nav controller
/*
    self.navigationItem.title = @"Huzzle Help";
    self.navigationItem.hidesBackButton = false;
    self.navigationItem.leftBarButtonItem.title = @"<Back";
*/
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)DoQuitButton:(id)sender {

    [self.delegate didFinishWithJumbleHelpView];
}
/*****************************************
 ios6+
 we don't want pic to rotate once we decided what orientation it is
 this is called after view presented & user decides to change device orientation
 ****************************************/

- (BOOL)shouldAutorotate {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    return NO;
}

/********************************************
 ios 6+
 for initial orientation
 ** ********************************************/
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}
/********************************************
 ********************************************/

@end
