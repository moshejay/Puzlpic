//
//  TileView.m
//  PhotoPicker
//
//  Created by moshe jacobson on 22/03/13.
//
//

#import "TileView.h"

@implementation TileView

@synthesize tileImage, aString, imageSize, moveHoriz,isSelected,originalCentre,isLocked,isInPlace,tempTag;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isSelected = false;
    }
    return self;
}

- (id)initWithAnimage:(UIImage *)image { // theIndex:(NSUInteger)index {
    
 	imageSize = CGSizeMake(image.size.width, image.size.height);
   	CGRect frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
	self = [super initWithFrame:frame];// Set self's frame to encompass the image
	if (self) {
		tileImage = image.copy;
	}
	return self;
}

- (void)dealloc {
    if(tileImage != nil)
        [tileImage release];
 	[super dealloc];
    return;
}

/********************************************
 Only override drawRect: if you perform custom drawing.
 An empty implementation adversely affects performance during animation.
 This is onll called when setting up the view!!
 ******************************************************/
- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    [tileImage drawAtPoint:(CGPointMake(0.0f, 0.0f))]; // Draw the placard at 0, 0 OF THIS VIEW not the superview

    if(isSelected) {
        [[UIColor redColor] set];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect frame = self.bounds;
        CGContextSetLineWidth(context,1.0);
//    else
//        [[UIColor yellowColor] set];
        UIRectFrame(frame);
    }
    return;
}

@end
