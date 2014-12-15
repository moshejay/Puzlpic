//
//  TableSettingsController.m
//  PuzlPic
//
//  Created by moshe jacobson on 9/04/13.
//
//

#import "TableSettingsController.h"
#import "SettingsAViewController.h"
#import "SettingsBViewController.h"
#import "SettingsCViewController.h"
#import "SettingsViewController.h"

@interface TableSettingsController ()

@end

@implementation TableSettingsController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"All Settings";
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];   
        cell.textLabel.font = [UIFont fontWithName:@"Marker Felt" size:17];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0.5 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    switch(indexPath.row) {
        case 0:
            cell.textLabel.text = @"Number of Tiles";
            break;
        case 1:
            cell.textLabel.text = @"Tile Lock and Snap";
            break;
        case 2:
            cell.textLabel.text = @"System";
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*

     // ...
     */
    SettingsAViewController *settingsAViewController;
    SettingsBViewController *settingsBViewController;
    SettingsViewController *settingsViewController;
    switch(indexPath.row) {
        case 0:
            // Pass the selected object to the new view controller.
            settingsAViewController = [[SettingsAViewController alloc] initWithNibName:@"SettingsAViewController" bundle:nil];
            [self.navigationController pushViewController:settingsAViewController animated:YES];
            [settingsAViewController release];            
            break;
        case 1:
            settingsBViewController = [[SettingsBViewController alloc] initWithNibName:@"SettingsBViewController" bundle:nil];
            [self.navigationController pushViewController:settingsBViewController animated:YES];
            [settingsBViewController release];
            break;
        case 2:
            settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
            [self.navigationController pushViewController:settingsViewController animated:YES];
            [settingsViewController release];
            break;
    }
   
}

@end
