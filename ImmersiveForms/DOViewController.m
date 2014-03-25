//
//  DOViewController.m
//  ImmersiveForms
//
//  Created by David Olesch on 3/24/14.
//  Copyright (c) 2014 David Olesch. All rights reserved.
//

#import "DOViewController.h"
#import "DOFormViewController.h"
#import "DOAnimator.h"

@interface DOViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation DOViewController

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

#pragma mark IBAction

- (IBAction)touchedAddButton:(id)sender {
    DOFormViewController *formViewController = [[DOFormViewController alloc] initWithNibName:nil bundle:nil];
    formViewController.transitioningDelegate = self;
    formViewController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:formViewController animated:YES completion:nil];
}

#pragma mark TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [NSString stringWithFormat:@"Quest %li",(long)indexPath.row];
    return cell;
}

#pragma mark UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    DOAnimator *animator = [DOAnimator new];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [DOAnimator new];
}

@end
