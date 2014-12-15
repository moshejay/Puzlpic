//
//  HelpTableTableViewController.m
//  PuzlPic
//
//  Created by moshe jacobson on 3/05/14.
//
//

#import "HelpTableTableViewController.h"
#import "HelpViewController.h"
#import "WhatsNewViewController.h"
#import "LinksViewController.h"

@interface HelpTableTableViewController ()
//@property (retain, nonatomic) IBOutlet UIView *myHeaderView;

@end

@implementation HelpTableTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Help and More";
    self.navigationItem.hidesBackButton = false;
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}
/*
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.myHeaderView;
}
*/

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"           Welcome to PuzlPic Ver 2.1";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //        cell.textLabel.font = [UIFont fontWithName:@"Marker Felt" size:17];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0.5 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    switch(indexPath.row){
        case 0:
            cell.textLabel.text = @"How to Play";
            break;
        case 1:
            cell.textLabel.text = @"Whats New";
            break;
        case 2:
            cell.textLabel.text = @"Important Links";
            break;
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    HelpViewController *hvc;
    LinksViewController *lvc;
    WhatsNewViewController *wvc;
    switch (indexPath.row) {
        case 0:
            hvc = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
            [self.navigationController pushViewController:hvc animated:YES];
            [hvc release];
            break;
        case 1:
            wvc = [[WhatsNewViewController alloc] initWithNibName:@"WhatsNewViewController" bundle:nil];
            [self.navigationController pushViewController:wvc animated:YES];
            [wvc release];
            break;
        case 2:
            lvc = [[LinksViewController alloc] initWithNibName:@"LinksViewController" bundle:nil];
            [self.navigationController pushViewController:lvc animated:YES];
            [lvc release];
            break;
    }
    return;
}

- (void)dealloc {
//    [_myHeaderView release];
    [super dealloc];
}
@end
