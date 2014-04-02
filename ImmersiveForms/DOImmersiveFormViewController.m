//
//  DOTextFieldView.m
//  ImmersiveForms
//
//  Created by David Olesch on 3/24/14.
//  Copyright (c) 2014 David Olesch. All rights reserved.
//

#import "DOImmersiveFormViewController.h"
#import "DOAnimator.h"

@interface DOImmersiveFormViewController () <UITextFieldDelegate,UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) NSMutableArray *textFields;
@property (strong, nonatomic) NSMutableArray *fieldViews;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *questions;
@property (nonatomic, copy) void (^formCompletionHandler)(NSArray *answers);
@property (strong, nonatomic) UIScrollView *scrollView;

@property (nonatomic) UIEdgeInsets oldContentInset;
@property (nonatomic) UIEdgeInsets oldIndicatorInset;
@property (nonatomic) UITextField *firstResponder;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *panAttachmentBehavior;

@property CGPoint snapPoint;

@end

@implementation DOImmersiveFormViewController

- (id)initWithTitle:(NSString *)title Questions:(NSArray *)questions andCompletionHandler:(void (^)(NSArray *answers))formCompletionHandler
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = title;
        self.questions = questions;
        self.formCompletionHandler = formCompletionHandler;
        
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self placeScrollView];
    [self placeTextFields];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textFields[0] becomeFirstResponder];
    self.firstResponder = self.textFields[0];
}

#pragma mark placement methods

- (void)placeScrollView
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.scrollView = [[UIScrollView alloc] initWithFrame:bounds];
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.frame) * self.questions.count, CGRectGetHeight(bounds))];
    self.scrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.scrollView.scrollEnabled = NO;
    [self.view addSubview:self.scrollView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [self.scrollView addGestureRecognizer:tapGestureRecognizer];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.scrollView];
}

- (void)placeFormLabelInView:(UIView *)view
{
    UILabel *formLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 320, 100)];
    formLabel.text = self.title;
    formLabel.textColor = [UIColor colorWithRed:43.f/255.f green:43.f/255.f blue:43.f/255.f alpha:1.f];
    formLabel.textAlignment = NSTextAlignmentCenter;
    formLabel.font = [UIFont fontWithName:@"Arial" size:28.0f];
    [view addSubview:formLabel];
}

- (void)placeTextFields
{
    self.textFields = [NSMutableArray array];
    self.fieldViews = [NSMutableArray array];
    CGRect fieldViewFrame = CGRectMake(-CGRectGetWidth(self.scrollView.frame), 75, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.view.bounds));
    for (int k = 0; k < self.questions.count ; k++) {
        fieldViewFrame.origin.x += CGRectGetWidth(self.scrollView.frame);
        UITextField *formField = [[UITextField alloc] initWithFrame:CGRectMake(0, 125, fieldViewFrame.size.width, 50)];
        formField.textAlignment = NSTextAlignmentCenter;
        formField.font = [UIFont fontWithName:@"Arial" size:28.f];
        if (k == self.questions.count - 1) {
            formField.returnKeyType = UIReturnKeyDone;
        }
        else {
            formField.returnKeyType = UIReturnKeyNext;
        }
        formField.delegate = self;
        formField.placeholder = self.questions[k][@"text"];
        formField.keyboardType = [self.questions[k][@"keyboard"] intValue];
        
        UIView *fieldView = [[UIView alloc] initWithFrame:fieldViewFrame];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        [fieldView addGestureRecognizer:panGesture];
        
        if (k == 0) {
            [self placeFormLabelInView:fieldView];
        }
        if (k % 2 == 0) {
            fieldView.backgroundColor = [UIColor colorWithRed:76.f/255.f green:217.f/255.f blue:100.f/255.f alpha:1.f];
        }
        else {
            fieldView.backgroundColor = [UIColor colorWithRed:52.f/255.f green:170.f/255.f blue:220.f/255.f alpha:1.f];;
        }
        fieldView.layer.cornerRadius = 6.f;
        [fieldView addSubview:formField];
        [self.scrollView addSubview:fieldView];
        [self.textFields addObject:formField];
        [self.fieldViews addObject:fieldView];
    }
}

#pragma mark keyboard show/hide handlers

- (void)keyboardShow:(NSNotification*)notification
{
    //increases the inset of the scrollview to make space for the keyboard
    self.oldContentInset = self.scrollView.contentInset;
    self.oldIndicatorInset = self.scrollView.scrollIndicatorInsets;
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
    [CATransaction setCompletionBlock:^{
        self.scrollView.scrollIndicatorInsets = self.oldIndicatorInset;
        self.scrollView.contentInset = self.oldContentInset;
    }];
    [self setFirstResponder:nil];
}

#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSUInteger textFieldIndex = [self.textFields indexOfObject:textField];
    UIView *fieldView = [self.fieldViews objectAtIndex:textFieldIndex];
    
    self.snapPoint = CGPointMake(fieldView.frame.origin.x + CGRectGetMidX(self.view.frame), CGRectGetHeight(self.view.frame)/2.f + 75.f);
    
    UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:fieldView snapToPoint:self.snapPoint];
    snapBehaviour.damping = 0.9f;
    [self.animator addBehavior:snapBehaviour];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIPushBehavior *pusher = [[UIPushBehavior alloc] initWithItems:@[fieldView] mode:UIPushBehaviorModeInstantaneous];
        pusher.pushDirection = CGVectorMake(0.0, -200.0);
        pusher.active = YES;
        [self.animator addBehavior:pusher];
    });
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    for (int k = 0 ; k < self.textFields.count ; k++) {
        if (self.textFields[k] == textField) {
            if (k + 1 < self.textFields.count) {
                [textField resignFirstResponder];
                [self.textFields[k+1] becomeFirstResponder];
                self.firstResponder = self.textFields[k+1];
            }
            else {
                [self dismissViewControllerAnimated:YES completion:nil];
                NSMutableArray *answers = [NSMutableArray array];
                for (int j = 0 ; j < self.questions.count; j++) {
                    [answers addObject:[self.textFields[j] text]];
                }
                self.formCompletionHandler([NSArray arrayWithArray:answers]);
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

#pragma mark UIPanGestureRecognizer

- (void)didPan:(UIPanGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    CGPoint location = [gesture locationInView:self.view];
    location.x = view.frame.origin.x + CGRectGetMidX(self.view.frame);

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self.animator removeAllBehaviors];
            
            //snapPoint is the center of the view reference view of the scrollView
            self.snapPoint = CGPointMake(view.frame.origin.x + CGRectGetMidX(self.view.frame), CGRectGetHeight(self.view.frame)/2.f + 75.f);
            
            self.panAttachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:view attachedToAnchor:location];
            [self.animator addBehavior:self.panAttachmentBehavior];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            self.panAttachmentBehavior.anchorPoint = location;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.animator removeAllBehaviors];
            
            UIDynamicItemBehavior *rotationBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[view]];
            rotationBehavior.allowsRotation = NO;
            [self.animator addBehavior:rotationBehavior];
            
            CGPoint velocity = [gesture velocityInView:self.view];
            if (velocity.y > 1.f) {
                [self.firstResponder resignFirstResponder];
                UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[view]];
                gravityBehavior.gravityDirection = CGVectorMake(0.f, 0.5f + velocity.y/100.f);
                [self.animator addBehavior:gravityBehavior];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:view snapToPoint:self.snapPoint];
                snapBehaviour.damping = 0.65f;
                [self.animator addBehavior:snapBehaviour];
            }
        }
            break;
        default:
            break;
    }
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
