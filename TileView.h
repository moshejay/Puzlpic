//
//  TileView.h
//  PhotoPicker
//
//  Created by moshe jacobson on 22/03/13.
//
//

#import <UIKit/UIKit.h>

@interface TileView : UIView {

    UIImage *tileImage;
    NSString *aString;
    CGSize imageSize;
    bool moveHoriz,isSelected,isLocked,isInPlace;
    CGPoint originalCentre;
    int tempTag;
}
@property (nonatomic, retain) UIImage *tileImage;
@property (nonatomic, retain) NSString *aString;
@property (assign) CGSize imageSize;
@property (assign) bool moveHoriz,isSelected,isLocked,isInPlace;
@property (assign) CGPoint originalCentre;
@property (assign) int tempTag;

// Initializer for this object
- (id)initWithFrame:(CGRect)frame;
- (id)initWithAnimage:(UIImage *)image; // theIndex:(NSUInteger)index;

@end
