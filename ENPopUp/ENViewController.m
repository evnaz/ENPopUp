//
//  ENViewController.m
//  ENPopUp
//
//  Created by Evgeny on 28.06.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

#import "ENViewController.h"
#import "UIViewController+ENPopUp.h"

@interface ENViewController ()

@end

@implementation ENViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPopUp:(id)sender
{
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUp"];
    vc.view.frame = CGRectMake(0, 0, 270.0f, 230.0f);
    [self presentPopUpViewController:vc];
}

@end
