//
//  DOTextFieldView.m
//  ImmersiveForms
//
//  Created by David Olesch on 3/24/14.
//  Copyright (c) 2014 David Olesch. All rights reserved.
//

#import "DOFormViewController.h"
#import "DOFormField.h"

@interface DOFormViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *textFields;
@property (strong, nonatomic) NSArray *questions;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (nonatomic) UIEdgeInsets oldContentInset;
@property (nonatomic) UIEdgeInsets oldIndicatorInset;
@property (nonatomic) CGPoint oldOffset;
@property (nonatomic) UITextView *firstResponder;

@end

@implementation DOFormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.questions = @[@"Quest name",@"Start message",@"Number of hints",@"Prize message"];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self placeScrollView];
    [self placeFormLabel];
    [self placeTextFields];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.textFields[0] becomeFirstResponder];
}

#pragma mark placement methods

- (void)placeScrollView
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.scrollView = [[UIScrollView alloc] initWithFrame:bounds];
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.frame) * self.questions.count, CGRectGetHeight(bounds))];
    self.scrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    self.scrollView.scrollEnabled = NO;
    [self.view addSubview:self.scrollView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [self.scrollView addGestureRecognizer:tapGestureRecognizer];
}

- (void)placeFormLabel
{
    UILabel *formLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 100)];
    formLabel.text = @"Create a Quest";
    formLabel.textColor = [UIColor whiteColor];
    formLabel.textAlignment = NSTextAlignmentCenter;
    formLabel.font = [UIFont fontWithName:@"Arial" size:28.0f];
    formLabel.backgroundColor = [UIColor blackColor];
    [self.view addSubview:formLabel];
}

- (void)placeTextFields
{
    self.textFields = [NSMutableArray array];
    CGRect textFieldFrame = CGRectMake(-CGRectGetWidth(self.scrollView.frame), 200, CGRectGetWidth(self.scrollView.frame), 100);
    for (int k = 0; k < self.questions.count ; k++) {
        textFieldFrame.origin.x += CGRectGetWidth(self.scrollView.frame);
        DOFormField *formField = [[DOFormField alloc] initWithFrame:textFieldFrame];
        [formField setBackgroundColor:[UIColor whiteColor]];
        [formField setAlpha:0.9];
        if (k == self.questions.count - 1) {
            [formField.fieldTextField setReturnKeyType:UIReturnKeyDone];
        }
        else {
            [formField.fieldTextField setReturnKeyType:UIReturnKeyNext];
        }
        formField.fieldTextField.delegate = self;
        formField.fieldLabel.text = self.questions[k];
        
        [self.scrollView addSubview:formField];
        [self.textFields addObject:formField.fieldTextField];
    }
}

#pragma mark keyboard show/hide handlers

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.firstResponder = textView;
}

- (void)keyboardShow:(NSNotification*)notification
{
    //increases the inset of the scrollview to make space for the keyboard
    self.oldContentInset = self.scrollView.contentInset;
    self.oldIndicatorInset = self.scrollView.scrollIndicatorInsets;
    self.oldOffset = self.scrollView.contentOffset;
    NSDictionary* userInfo = [notification userInfo];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    rect = [self.scrollView convertRect:rect fromView:nil];
    CGRect frame = self.firstResponder.frame;
    CGFloat y = CGRectGetMaxY(frame) + rect.size.height - self.scrollView.bounds.size.height;
    if (rect.origin.y < CGRectGetMaxY(frame))
        [self.scrollView setContentOffset:CGPointMake(0, y) animated:YES];
    UIEdgeInsets insets;
    insets = self.scrollView.contentInset;
    insets.bottom = rect.size.height;
    self.scrollView.contentInset = insets;
    insets = self.scrollView.scrollIndicatorInsets;
    insets.bottom = rect.size.height;
    self.scrollView.scrollIndicatorInsets = insets;
}

- (void)keyboardHide:(NSNotification*)notification
{
    //removes the inset added in keyboardShow:
    [self.scrollView setContentOffset:self->_oldOffset animated:YES];
    [CATransaction setCompletionBlock:^{
        self.scrollView.scrollIndicatorInsets = self.oldIndicatorInset;
        self.scrollView.contentInset = self.oldContentInset;
    }];
    [self setFirstResponder:nil];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    for (int k = 0 ; k < self.textFields.count ; k++) {
        if (self.textFields[k] == textField) {
            if (k + 1 < self.textFields.count) {
                [self.textFields[k+1] becomeFirstResponder];
            }
            else {
                [self dismissViewControllerAnimated:YES completion:nil];
                for (int j = 0 ; j < self.questions.count; j++) {
                    NSLog(@"%@: %@",self.questions[j],[self.textFields[j] text]);
                }
            }
        }
    }
    return YES;
}

#pragma mark UITapGestureRecognizer

- (void)tapGestureHandler:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:sender.view];
    UIView *viewTouched = [sender.view hitTest:point withEvent:nil];
    if ([viewTouched isKindOfClass:[UIScrollView class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
