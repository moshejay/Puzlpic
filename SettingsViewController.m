//
//  SettingsViewController.m
//  PuzlPic
//
//  Created by moshe jacobson on 3/04/13.
//
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    self.navigationItem.title = @"System Settings";
    // Configure the select button on the navigator bar...the cancel is done automatically if we do nothing.
    // initWithBarButtonSystemItem:uib UIBarButtonSystemItemAction target:self action:@selector(ActionProd)];
//    UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(SaveSettings)];
//    self.navigationItem.rightBarButtonItem = selectButton;
//    self.navigationItem.rightBarButtonItem.enabled = YES;
//    [selectButton release];
    self.navigationItem.hidesBackButton = false;
//    self.tableView.rowHeight *= 1.5;
//    [self.tableView setBackgroundColor:[UIColor colorWithRed:0 green:1 blue:0.5 alpha:1]];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/***************************************************
 ***************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}
/***************************************************
 ***************************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0)
        return 5;
    else if(section == 1)
        return 3;
    return 2;
}
/***************************************************
 set a custom height for each header
 ***************************************************/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return 90;//140;
    else if (section == 1)
        return 30;//100;
    return 30;//80;
}
/***************************************************
 set a custom view in the header
 ***************************************************/
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *alabel = [[[UILabel alloc] init] autorelease];
    if(section == 0)
    {
        alabel.text = @"Touch a row to select and change the setting.\n\nMessages:";
        alabel.numberOfLines = 5;
    }
    else if(section == 1)
    {
        alabel.text = @"Sounds:";
        alabel.numberOfLines = 1;
    }
    else {
        alabel.text = @"Other Settings:";
        alabel.numberOfLines = 1;
    }
//    alabel.font = [UIFont fontWithName:@"Marker Felt" size:17];
//    alabel.textColor = [UIColor whiteColor];
    alabel.backgroundColor = [UIColor colorWithRed:0.4 green:1.0 blue:1.0 alpha:1]; // [UIColor colorWithRed:0.24 green:1.0 blue:0.78 alpha:1];//green
    return alabel;
}
/****************************************************
 Set the header text for a section
 ****************************************************/
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"   Messages and Settings:";
    else if(section == 1)
        return @"   Sounds:";
    return @"   Settings:";
}
 */
/****************************************************
 create the cell format..this is called whenever
 the table is told to reload itself
 ****************************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    bool tickit = true;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont fontWithName:@"Marker Felt" size:17];
//        cell.backgroundColor = [UIColor colorWithRed:0.65 green:0.78 blue:1 alpha:1];// [UIColor colorWithRed:0 green:1 blue:0.5 alpha:1];
        cell.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0.5 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.numberOfLines = 0;
    }
    if(indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Show how to quit from the puzzle\non entry to the puzzle screen?";
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicTouchMsgOff"];
                break;
            case 1:
                cell.textLabel.text = @"Show the hidden tiles message?";
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicHiddenTilesMsgOff"];
                break;
            case 2:
                cell.textLabel.text = @"Confirm to quit from the puzzle screen?";
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicQuitMsgOff"];
                break;
            case 3:
                cell.textLabel.text = @"Confirm that the puzzle has been saved?";
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicSaveMsgOff"];
                break;
            case 4:
                cell.textLabel.text = @"Show how to hide the original picture on the puzzle screen?";
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicOrigPicOff"];
                break;
            default:
                cell.textLabel.text = @"";
                break;
        }
    }
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Make a sound when a tile is correctly positioned?";
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicSoundOff"];
                break;
            case 1:
                cell.textLabel.text = @"Make a sound when the puzzle is complete?";
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"FinishedPuzlPicSoundOff"];
                break;
            case 2:
                cell.textLabel.text = @"Make a sound when a toolbar button is touched?";
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicToolbarSoundOff"];
                break;
            default:
                cell.textLabel.text = @"";
                break;
        }
    }
    else {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Show the original picture above the tiles in the puzzle screen?";
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicOnTheBot"];
                break;
            case 1:
                cell.textLabel.text = @"Show the toolbar on entry to the puzzle screen?";
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicPuzlToolbarOff"];
                break;
            default:
                cell.textLabel.text = @"";
                break;
        }
        
    }
    if(tickit)  // note the converse!!!
        cell.accessoryType = UITableViewCellAccessoryNone;
    else
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

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
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    bool tickit = true;
    if(indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicTouchMsgOff"] ^ 1; //xor'd original value becomes new value
                [[NSUserDefaults standardUserDefaults] setBool:tickit forKey:@"PuzlPicTouchMsgOff"];
                break;
            case 1:
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicHiddenTilesMsgOff"] ^ 1;
                [[NSUserDefaults standardUserDefaults] setBool:tickit forKey:@"PuzlPicHiddenTilesMsgOff"];
                break;
            case 2:
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicQuitMsgOff"] ^ 1;
                [[NSUserDefaults standardUserDefaults] setBool:tickit forKey:@"PuzlPicQuitMsgOff"];
                break;
            case 3:
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicSaveMsgOff"] ^ 1;
                [[NSUserDefaults standardUserDefaults] setBool:tickit forKey:@"PuzlPicSaveMsgOff"];
                break;
            case 4:
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicOrigPicOff"] ^ 1;
                [[NSUserDefaults standardUserDefaults] setBool:tickit forKey:@"PuzlPicOrigPicOff"];
                break;
        }
    }
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicSoundOff"] ^ 1;
                [[NSUserDefaults standardUserDefaults] setBool:tickit forKey:@"PuzlPicSoundOff"];
                break;
            case 1:
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"FinishedPuzlPicSoundOff"] ^ 1;
                [[NSUserDefaults standardUserDefaults] setBool:tickit forKey:@"FinishedPuzlPicSoundOff"];
                break;
            case 2:
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicToolbarSoundOff"] ^ 1;
                [[NSUserDefaults standardUserDefaults] setBool:tickit forKey:@"PuzlPicToolbarSoundOff"];
                break;
            default:
                cell.textLabel.text = @"";
                break;
        }
    }
    else {
        switch (indexPath.row) {
            case 0:
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicOnTheBot"] ^ 1;
                [[NSUserDefaults standardUserDefaults] setBool:tickit forKey:@"PuzlPicOnTheBot"];
                break;
            case 1:
                tickit = [[NSUserDefaults standardUserDefaults] boolForKey:@"PuzlPicPuzlToolbarOff"] ^ 1;
                [[NSUserDefaults standardUserDefaults] setBool:tickit forKey:@"PuzlPicPuzlToolbarOff"];
                break;
            default:
                cell.textLabel.text = @"";
                break;
        }
        
    }

    if(tickit ^ 1) // note we dont use the CONVERSE here cos already conversed
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return;

}
@end
