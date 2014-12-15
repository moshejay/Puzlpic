//
//  WhatsNewViewController.m
//  PuzlPic
//
//  Created by moshe jacobson on 25/04/14.
//
//

#import "WhatsNewViewController.h"

@interface WhatsNewViewController ()
@property (nonatomic,retain) IBOutlet UITextView *theText;
@end

@implementation WhatsNewViewController

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
    self.navigationItem.title = @"Whats New??";
    self.navigationItem.hidesBackButton = false;
    self.theText.text = [self.theText.text stringByAppendingString:@
                         "In Ver 2.1:\nOn the Main screen: The Icons for Received and Sent Puzzles.\nOn the Puzzle Screen: The Icon for Sending a Puzzle.\n\nYou can now SEND and RECEIVE puzzles via email (other methods will follow in time). The puzzle that will be sent is the one as it CURRENTLY appears on the screen (so you could send the same puzzle as different variations).\nYou ALSO have the option of including or excluding the ORIGINAL image. If the original image is excluded, it means that the receiver cannot peek at the complete image of the puzzle they are trying to do.\n\nSend puzzles to your friends and challenge them to complete them. Use PuzlPic for invitations, fun, promotions, competitions and more.\nBe aware that the recipients will need to have PuzlPic or PuzlPic Lite installed on their iPhone/iPad/iPod.\nPlease take the time to read the help on the previous screen. Especially the parts about what you can do with your Sent and Received puzzles.\n      ------------------------------"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
