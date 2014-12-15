/*
     File: OverlayViewController.h 
 Abstract: The secondary view controller managing the overlap view to the camera.
  
  Version: 1.2 
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@protocol OverlayViewControllerDelegate;

@interface OverlayViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    id <OverlayViewControllerDelegate> delegate;
}    

@property (nonatomic, assign) id <OverlayViewControllerDelegate> delegate;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType;

@end

@protocol OverlayViewControllerDelegate
- (void)didTakePicture:(UIImage *)picture;
- (void)didFinishWithCamera;
@end
