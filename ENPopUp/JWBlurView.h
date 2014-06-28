//
//  JWBlurView.h
//  iOS7_blur
//
//  Created by Jake Widmer on 12/14/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface JWBlurView : UIView

- (void) setBlurColor:(UIColor *)blurColor;
- (void) setBlurAlpha:(CGFloat)alphaValue;

@end
