//
//  HelpViewController.m
//  PhotoPicker
//
//  Created by moshe jacobson on 1/04/13.
//
//

#import "HelpViewController.h"
#import "WhatsNewViewController.h"

@interface HelpViewController ()
@property (nonatomic,retain) IBOutlet UITextView *theText;
-(IBAction)WhatsNewAction;
@end

@implementation HelpViewController


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
    self.navigationItem.title = @"How to Play";
    self.navigationItem.hidesBackButton = false;
//    UIBarButtonItem *whatsNewButton = [[UIBarButtonItem alloc] initWithTitle:@"WhatsNew?>" style:UIBarButtonItemStyleBordered target:self action:@selector(WhatsNewAction)];
//    self.navigationItem.rightBarButtonItem = whatsNewButton;
//    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.title = @"<Back";
/*
     if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
         self.theText.text = @"WELCOME TO: PuzlPic Ver 2.1\nWe hope you have as much fun playing it as we do.\n\n                                        TO PLAY THE GAME";
    
     else
         self.theText.text = @"WELCOME TO: PuzlPic Ver 2.1\nWe hope you have as much fun playing it as we do.\n\n                      TO PLAY THE GAME";
*/
    self.theText.text = @"\n            THE WELCOME SCREEN:\nTouch the button that shows 2 gears to get to all the different settings.\n\nTouch the button that shows a drawer full of photos. This will bring up your camera roll. Select a photo.\n      -OR-\nTouch the button that shows a camera and take a picture (be aware that the picture is NOT saved in the camera roll)!\nOnce you have selected or taken a picture, touch the button that shows a puzzle.\nThe selected picture will be displayed all jumbled up.\nNow put it back together!\n\n      -OR-\nTouch the button that shows a bookmark to resume a previously saved puzzle.\n      -OR-\nTouch the button that shows an In-box, this shows all the puzzles you have received AND have saved. The last puzzle received is ALWAYS called 'LastReceivedPuzzle'.Touch a row to redisplay the puzzle.\n      -OR-\nTouch the button that shows a Sent-box, this shows all the puzzles you have sent. Touch a row to redisplay the puzzle.\n\n            THE PUZZLE SCREEN:\nTouch a tile to select it, then move it to where you want to place it.\nIf a tile covers another tile, double-tap the tile to send it behind that other tile.\nA tile that is within the snap distance will snap into position. The shorter the snap distance you set, the closer the tile must be to its correct position before it will snap into place.\nIf you have set tile locking to YES, a tile that has been snapped into position will not move after it has snapped into position.\nIMPORTANT - TOUCH (you can also move it) THE LITTLE FLOATING ARROW ICON TO DISPLAY OR HIDE THE TOOLBAR.\nNote that the QUIT BUTTON is the 'X' button on the left side of the toolbar.\nTouch the question mark button on the toolbar for additonal help.\nTo SEND a puzzle in its CURRENT layout, touch the Send-box button and follow the instructions from there.\n      ------------------------------";
/*
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.theText.text= [self.theText.text stringByAppendingString:@"     support@SolveItByDesign.com.\n\n\n                        Happy Playing! \n                              (c)2014\n  by M&M&R at www.SolveITbyDesign.com"];
    else
        self.theText.text = [self.theText.text stringByAppendingString:@"   support@SolveItByDesign.com.\n\n\n                       Happy Playing!\n                             (c)2014\n  by M&M&R at www.SolveITbyDesign.com"];
 */
   }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    _theText = nil;
    return;
}

- (void)dealloc {
    [_theText release];
    [super dealloc];
    return;
}

/*****************************************
 pressed the whatsnew button
 ******************************************/
-(IBAction)WhatsNewAction {

    WhatsNewViewController *hvc = [[WhatsNewViewController alloc] initWithNibName:@"WhatsNewViewController" bundle:nil];
    [self.navigationController pushViewController:hvc animated:YES];
    [hvc release];
    return;
}

@end
