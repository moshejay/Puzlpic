//
//  JumbleViewViewController.h
//  PhotoPicker
//
//  Created by moshe jacobson on 23/03/13.
//
//

#import "jumbleHelpViewController.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#define PUZLPIC_VER 2

@protocol JumbleViewControllerDelegate;

@interface JumbleViewController : UIViewController <JumbleHelpViewControllerDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UITextFieldDelegate>
{
    id <JumbleViewControllerDelegate> delegate;
    UIImageView *passedImage;
    CGPoint theTouchPoint;
    BOOL isRecvdImage;
    NSString *recvdFileName;
}
@property (assign) BOOL isRecvdImage,isSentImage;
@property (nonatomic,copy) NSString *recvdFileName;
@property (nonatomic, assign) id <JumbleViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIImageView *passedImage;
@property (assign) CGPoint theTouchPoint;


-(void) SetupTheImage:(UIImage *)imageToUse;
-(void) SetupTheView;
-(void)animateFirstTouchAtPoint;
-(void)theLongPressAction:(UILongPressGestureRecognizer *)gestureRecognizer;
-(void)DoTheImageRestore;
-(void)DoTheWholeRestore:(NSString *)filePath;
@end



@protocol JumbleViewControllerDelegate
- (void)didFinishWithJumbleView;
@end