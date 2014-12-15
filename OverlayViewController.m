/*
     File: OverlayViewController.m 
 Abstract: The secondary view controller managing the overlap view to the camera.
 borrowed from photopicker but removed all timing stuff
  
  Version: 1.2 
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
  
 */

#import "OverlayViewController.h"

enum
{
	kOneShot,       // user wants to take a delayed single shot
	kRepeatingShot  // user wants to take repeating shots
};

@interface OverlayViewController ( )

@property (assign) SystemSoundID tickSound;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *takePictureButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;

// camera page (overlay view)
- (IBAction)done:(id)sender;
- (IBAction)takePhoto:(id)sender;

@end

@implementation OverlayViewController

@synthesize delegate;

#pragma mark -
#pragma mark OverlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tick" ofType:@"aiff"]],&_tickSound);
        self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
        self.imagePickerController.delegate = self;
    }
    return self;
}

- (void)viewDidUnload {
    
    self.takePictureButton = nil;
    self.cancelButton = nil;
    [super viewDidUnload];
}

- (void)dealloc {

    [_takePictureButton release];
    [_cancelButton release];
    [_imagePickerController release];
    AudioServicesDisposeSystemSoundID(_tickSound);
    [super dealloc];
}
/****************************************
 set the source type & if camera set up the interface
 for camera, by default allowsEditing = NO & mediaType = kUTTypeImage (still images)
 *********************************************************/
- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType {

    self.imagePickerController.sourceType = sourceType;

    if (sourceType == UIImagePickerControllerSourceTypeCamera) { // user wants to use the camera interface
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) { // but don't use overlay if its on the iPad...chis said it didn't work!!
            self.imagePickerController.showsCameraControls = NO;
            if ([[self.imagePickerController.cameraOverlayView subviews] count] == 0) {
                // setup our custom overlay view for the camera
                // ensure that our custom view's frame fits within the parent frame
                CGRect overlayViewFrame = self.imagePickerController.cameraOverlayView.frame;
                CGRect newFrame = CGRectMake(0.0,CGRectGetHeight(overlayViewFrame) - self.view.frame.size.height - 10.0,
                                                 CGRectGetWidth(overlayViewFrame), self.view.frame.size.height + 10.0);
                self.view.frame = newFrame;
                [self.imagePickerController.cameraOverlayView addSubview:self.view];
            }
        }
    }
    return;
}
/**********************************************
 called when the parent application receives a memory warning
 we have been warned that memory is getting low, stop all timers
 **************************************************/
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    return;
}
/**********************************************
 update the UI after an image has been chosen or picture taken
**********************************************/
- (void)finishAndUpdate {

    [self.delegate didFinishWithCamera];  // tell our delegate we are done with taking/selecting the image
    self.cancelButton.enabled = YES;     // restore the state of our overlay toolbar buttons
    self.takePictureButton.enabled = YES;
    return;
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate
/*********************************************************
 this get called when an image has been chosen from the library or taken from the camera
*********************************************************/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (self.delegate) // give the taken picture to our delegate
        [self.delegate didTakePicture:image];
    [self finishAndUpdate];
    return;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.delegate didFinishWithCamera];    // tell our delegate we are finished with the picker
}

#pragma mark -
#pragma mark Camera Actions
/**********************************************
 the camera
 **********************************************/
- (IBAction)done:(id)sender {
    // dismiss the camera
    // but not if it's still taking timed pictures
   [self finishAndUpdate];
}


- (IBAction)takePhoto:(id)sender {
    [self.imagePickerController takePicture];
    return;
}


@end

