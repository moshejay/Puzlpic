/*
     File: MyViewController.h 
 Abstract: The main view controller of this app.
  
  Version: 1.2 
  
  Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import <UIKit/UIKit.h>

#import "OverlayViewController.h"
#import "JumbleViewController.h"

@interface MyViewController : UIViewController <UIImagePickerControllerDelegate, OverlayViewControllerDelegate, JumbleViewControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate>

- (void)didFinishWithJumbleView;
- (void) DoEmailedPuzzle;

@end

