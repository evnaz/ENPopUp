//
//  UIViewController+ENPopUp.h
//  ENPopUp
//
//  Created by Evgeny on 28.06.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ENPopUp)

- (void)presentPopUpViewController:(UIViewController *)popupViewController;
- (void)dismissPopUpViewController;

@end
