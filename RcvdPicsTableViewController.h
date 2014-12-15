//
//  RcvdPicsTableViewController.h
//  PuzlPic
//
//  Created by moshe jacobson on 22/04/14.
//
//

#import <UIKit/UIKit.h>
#import "JumbleViewController.h"

@interface RcvdPicsTableViewController : UITableViewController<JumbleViewControllerDelegate>
@property BOOL lookAtSent;
- (void)didFinishWithJumbleView;
@end
