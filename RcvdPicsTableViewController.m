//
//  RcvdPicsTableViewController.m
//  PuzlPic
//
//  Created by moshe jacobson on 22/04/14.
//
//

#import "RcvdPicsTableViewController.h"

@interface RcvdPicsTableViewController ()
@property NSInteger fileCount;
@property NSMutableArray *fileNameArray;
@property (nonatomic, retain) JumbleViewController *jumbleViewController;
@end

@implementation RcvdPicsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    if(self.lookAtSent)
        self.navigationItem.title = @"Puzzles Sent";
    else
        self.navigationItem.title = @"Puzzles Received";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.hidesBackButton = false;
    _fileNameArray = [[NSMutableArray alloc] init]; // self.fileNameArray did not work here!!!
    [self PopulateFileArray];
    self.jumbleViewController = [[[JumbleViewController alloc] initWithNibName:@"JumbleViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.jumbleViewController.delegate = self;
    return;
}

- (void)viewDidUnload
{
    self.jumbleViewController = nil;
    self.fileNameArray = nil;
    return;
}

- (void)dealloc
{
    [_jumbleViewController release];
    [_fileNameArray removeAllObjects];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)PopulateFileArray {

    NSString *filePath = @"";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *whichDir = @"";
    if(self.lookAtSent)
        whichDir = @"Sent";
    else
        whichDir = @"Received";
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/%@/",NSHomeDirectory(),whichDir];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:filePath];
    
    NSString *file;
    while ((file = [dirEnum nextObject])) {
        if ([[file pathExtension] isEqualToString: @"pzlpic"]) {
            NSString *fileName = [file lastPathComponent];
            fileName = [fileName stringByReplacingOccurrencesOfString:@".pzlpic" withString:@""];
            [self.fileNameArray addObject:fileName];
        }
    }
    self.fileCount = [self.fileNameArray count];
}
#pragma mark - Table view data source
    // Return the number of sections.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

    // Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger ant = [self.fileNameArray count];
    return ant;
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
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.textLabel.text = [self.fileNameArray objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
// so now we load the image manipulation screen
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *filePath = @"";
    NSString *whichDir = @"";
    if(self.lookAtSent) {
        whichDir = @"Sent";
        self.jumbleViewController.isRecvdImage = FALSE;
        self.jumbleViewController.isSentImage = TRUE;
    }
    else {
        whichDir = @"Received";
        self.jumbleViewController.isRecvdImage = true;
        self.jumbleViewController.isSentImage = FALSE;
    }
    NSString *fileName = @"";
    fileName = [fileName stringByAppendingFormat:@"%@.pzlpic",(NSString *)[self.fileNameArray objectAtIndex:indexPath.row]]; // must add ext cos when we get from email we use ext!
    filePath = [filePath stringByAppendingFormat:@"%@/Documents/%@/%@",NSHomeDirectory(),whichDir,fileName];
    self.jumbleViewController.recvdFileName = fileName;
    
    NSData *theData = [NSData dataWithContentsOfFile:filePath];
    UIImage *animage = nil;
    NSKeyedUnarchiver *theunarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
    animage = [theunarchive decodeObjectForKey:@"passed image image"];
    [theunarchive finishDecoding];
    [theunarchive release];

    [self.jumbleViewController SetupTheImage:animage]; // ensures that _theImage is populated prior to the view being presented

    [self presentViewController:self.jumbleViewController animated:YES completion:NULL]; // presentModalViewController is deprecated
    [self.jumbleViewController DoTheWholeRestore:filePath];
    return;
}

                                        /***********************************************
                                         table editing
                                         ***********************************************/
// brings up the delete control as well
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
/*
    if (editing)
        self.navigationItem.rightBarButtonItem.enabled = false;
    else
        self.navigationItem.rightBarButtonItem.enabled = TRUE;
 */
    return;
}

// Override to support editing the table view....
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *filePath = @"";
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *whichDir = @"";
        if(self.lookAtSent)
            whichDir = @"Sent";
        else
            whichDir = @"Received";
        filePath = [filePath stringByAppendingFormat:@"%@/Documents/%@/%@.pzlpic",NSHomeDirectory(),whichDir,(NSString *)[self.fileNameArray objectAtIndex:indexPath.row]];
        if([fileManager removeItemAtPath:filePath error:nil] == false) // if something goes wrong just exit
            return;
        
        /*** because we are NOT using a managed context we can simply do it like this...don't delete this cos will foreget it  ***/
        [self.fileNameArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade]; // Delete the row from the data source
    }
    /* we aren't allowing insertions
     else if (editingStyle == UITableViewCellEditingStyleInsert) {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     */
}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
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

/*****************************************
 called back from JumbleViewController and it was a push not a modal
 cos we the delegate
 ******************************************/
- (void)didFinishWithJumbleView {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [_fileNameArray removeAllObjects];
    [self PopulateFileArray];
    [self.tableView reloadData];
    return;
}

@end
