//
//  jumbleHelpViewController.h
//  PuzlPic
//
//  Created by moshe jacobson on 21/04/13.
//
//

#import <UIKit/UIKit.h>


@protocol JumbleHelpViewControllerDelegate;

@interface jumbleHelpViewController : UIViewController 
{
    id <JumbleHelpViewControllerDelegate> delegate;
}
@property (nonatomic, assign) id <JumbleHelpViewControllerDelegate> delegate;
@end

@protocol JumbleHelpViewControllerDelegate
- (void)didFinishWithJumbleHelpView;
@end