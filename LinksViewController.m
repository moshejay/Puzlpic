//
//  LinksViewController.m
//  PuzlPic
//
//  Created by moshe jacobson on 3/05/14.
//
//

#import "LinksViewController.h"

@interface LinksViewController ()

@property (nonatomic, retain) NSURL *appStoreURL,*facebookURL;

- (IBAction)OurFacebookPage:(id)sender;
- (IBAction)OurAppStorePage:(id)sender;
- (void)openReferralURL:(NSURL *)referralURL;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (IBAction)DoAnEmail:(id)sender;

@end

@implementation LinksViewController

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
    self.navigationItem.title = @"Important Links";
    self.navigationItem.hidesBackButton = false;
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OurFacebookPage:(id)sender {
    NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/373618046091027"];
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        NSURL *aurl = [[NSURL alloc] initWithString:@"https://www.facebook.com/pages/Puzlpic/373618046091027"];
        [[UIApplication sharedApplication] openURL:aurl];
        [aurl release];
    }
}
/*****************************************
taken from lite ver but that didn't work so retrieved from 
http://forums.coronalabs.com/topic/38789-ios7-fails-to-launch-app-store-app-review-page/
 tech q&a QA1629
 note that https didn't work...it gives a nill from connection, but http does work.
 ******************************************/
- (IBAction)OurAppStorePage:(id)sender {
//    NSURL *aurl = [[NSURL alloc] initWithString:@"https://itunes.apple.com/us/app/puzlpic/id633071376?mt=8&uo=4"];
    NSURL *aurl = [[NSURL alloc] initWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=633071376&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"];
//    [self openReferralURL:aurl];
    [[UIApplication sharedApplication] openURL:aurl];
    [aurl release];
}
/*****************************************
 Process a LinkShare/TradeDoubler/DGM URL to something iPhone can handle
 ******************************************/
- (void)openReferralURL:(NSURL *)referralURL
{
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:referralURL]
                                                           delegate:self startImmediately:YES];
    [con release];
    return;
}
/*****************************************
 Save the most recent URL in case multiple redirects occur
 "iTunesURL" is an NSURL property decalred at top
 *****************************************/
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    self.appStoreURL = [response URL];
    if( [self.appStoreURL.host hasSuffix:@"itunes.apple.com"]) {
        [connection cancel];
        [self connectionDidFinishLoading:connection];
        return nil;
    }
    return request;
}
/*****************************************
 No more redirects; use the last URL saved
 *****************************************/
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] openURL:self.appStoreURL];
    return;
}
//-------------------------------------------------------
//
//    requirements for emailing
//
//-------------------------------------------------------
- (IBAction)DoAnEmail:(id)sender {
   
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"PuzlPic Support"] ;
    
    //--- Set up the recipients ---
    NSArray *toRecipients = [NSArray arrayWithObjects:@"support@SolveITbyDesign.com",nil];
    //      NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com",@"third@example.com", nil];
    //    NSArray *bccRecipients = [NSArray arrayWithObjects:@"four@example.com",nil];
    
    [picker setToRecipients:toRecipients];
    //    [picker setCcRecipients:ccRecipients];
    //    [picker setBccRecipients:bccRecipients];
    
    //------ Fill out the email body text ----------
    NSString *emailBody = @"";
    emailBody = [emailBody stringByAppendingString:@"Hi PuzlPic Team:\n"];
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

@end
