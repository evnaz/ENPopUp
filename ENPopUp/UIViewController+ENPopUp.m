//
//  UIViewController+ENPopUp.m
//  ENPopUp
//
//  Created by Evgeny on 28.06.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

#import "UIViewController+ENPopUp.h"
#import "JWBlurView.h"
#import <objc/runtime.h>

static void * ENPopupViewControllerPropertyKey = &ENPopupViewControllerPropertyKey;

static CGFloat const kAnimationDuration = .4f;
static CGFloat const kRotationAngle = 70.f;

static NSInteger const kENPopUpOverlayViewTag   = 351301;
static NSInteger const kENPopUpViewTag          = 351302;
static NSInteger const kENPopUpBluredViewTag    = 351303;

@implementation UIViewController (ENPopUp)

#pragma mark - Public Methods
- (void)presentPopUpViewController:(UIViewController *)popupViewController
{
	[self presentPopUpViewController:popupViewController completion:nil];
}

- (void)presentPopUpViewController:(UIViewController *)popupViewController completion:(void (^)(void))completionBlock
{
    self.en_popupViewController = popupViewController;
    [self presentPopUpView:popupViewController.view completion:completionBlock];
}

- (void)dismissPopUpViewController
{
	[self dismissPopUpViewControllerWithcompletion:nil];
}

- (void)dismissPopUpViewControllerWithcompletion:(void (^)(void))completionBlock
{
    UIView *sourceView = [self topView];
    JWBlurView *blurView = (JWBlurView *)[sourceView viewWithTag:kENPopUpBluredViewTag];
    UIView *popupView = [sourceView viewWithTag:kENPopUpViewTag];
    UIView *overlayView = [sourceView viewWithTag:kENPopUpOverlayViewTag];
    [self performDismissAnimationInSourceView:sourceView withBlurView:blurView popupView:popupView overlayView:overlayView completion:completionBlock];
}

#pragma mark - Getters & Setters
- (UIViewController *)en_popupViewController
{
    return objc_getAssociatedObject(self, ENPopupViewControllerPropertyKey);
}

- (void)setEn_popupViewController:(UIViewController *)en_popupViewController
{
    objc_setAssociatedObject(self, ENPopupViewControllerPropertyKey, en_popupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

#pragma mark - View Handling
- (void)presentPopUpView:(UIView *)popUpView completion:(void (^)(void))completionBlock
{
    UIView *sourceView = [self topView];
    // Check if source view controller is not in destination
    if ([sourceView.subviews containsObject:popUpView]) return;
    
    // Add overlay
    UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayView.tag = kENPopUpOverlayViewTag;
    overlayView.backgroundColor = [UIColor clearColor];
    
    // Add Blured View
    JWBlurView *bluredView = [[JWBlurView alloc] initWithFrame:overlayView.bounds];
    bluredView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bluredView.tag = kENPopUpBluredViewTag;
    [bluredView setBlurAlpha:.0f];
    [bluredView setAlpha:.0f];
    [bluredView setBlurColor:[UIColor clearColor]];
    bluredView.backgroundColor = [UIColor clearColor];
    [overlayView addSubview:bluredView];
    
    // Make the background clickable
    UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    dismissButton.backgroundColor = [UIColor clearColor];
    dismissButton.frame = sourceView.bounds;
    [overlayView addSubview:dismissButton];
    
    [dismissButton addTarget:self action:@selector(dismissPopUpViewController)
            forControlEvents:UIControlEventTouchUpInside];
    
    // Customize popUpView
    popUpView.layer.cornerRadius = 3.5f;
    popUpView.layer.masksToBounds = YES;
    popUpView.layer.zPosition = 99;
    popUpView.tag = kENPopUpViewTag;
    popUpView.center = overlayView.center;
    [popUpView setNeedsLayout];
    [popUpView setNeedsDisplay];
    
    [overlayView addSubview:popUpView];
    [sourceView addSubview:overlayView];

    [self setAnimationStateFrom:popUpView];
    [self performAppearAnimationWithBlurView:bluredView popupView:popUpView completion:completionBlock];
}



#pragma mark - Animation
- (void)setAnimationStateFrom:(UIView *)view
{
    CALayer *layer = view.layer;
    layer.transform = [self transform3d];
}

- (CATransform3D)transform3d
{
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, 0, 200.f, 0);
    transform.m34 = 1.0/800.0;
    transform = CATransform3DRotate(transform, kRotationAngle*M_PI/180.f, 1.f, .0f, .0f);
    CATransform3D scale = CATransform3DMakeScale(.7f, .7f, .7f);
    return CATransform3DConcat(transform, scale);
}

- (void)performAppearAnimationWithBlurView:(JWBlurView *)blurView popupView:(UIView *)popupView completion:(void (^)(void))completionBlock
{
    
    CATransform3D transform;
    transform = CATransform3DIdentity;
    [UIView animateWithDuration:kAnimationDuration
                     animations:^ {
                         [self.en_popupViewController viewWillAppear:NO];
                         [blurView setAlpha:1.f];
                         popupView.layer.transform = transform;
                     }
                     completion:^(BOOL finished) {
                         [self.en_popupViewController viewDidAppear:NO];
						 if (completionBlock != nil) {
							 completionBlock();
						 }
                     }];
}


- (void)performDismissAnimationInSourceView:(UIView *)sourceView
                               withBlurView:(JWBlurView *)blurView
                                  popupView:(UIView *)popupView
                                overlayView:(UIView *)overlayView
								 completion:(void (^)(void))completionBlock
{
    CATransform3D transform = [self transform3d];
    [UIView animateWithDuration:kAnimationDuration
                     animations:^ {
                         [self.en_popupViewController viewWillDisappear:NO];
                         [blurView setAlpha:0.f];
                         popupView.layer.transform = transform;
                     }
                     completion:^(BOOL finished) {
                         [popupView removeFromSuperview];
                         [blurView  removeFromSuperview];
                         [overlayView  removeFromSuperview];
                         [self.en_popupViewController viewDidDisappear:NO];
                         self.en_popupViewController = nil;
						 if (completionBlock != nil) {
							 completionBlock();
						 }
                     }];
}

#pragma mark - Getters

- (UIView*)topView {
    UIViewController *recentView = self;
    while (recentView.parentViewController != nil) {
        recentView = recentView.parentViewController;
    }
    return recentView.view;
}

@end
