//
//  DOTextFieldView.h
//  ImmersiveForms
//
//  Created by David Olesch on 3/24/14.
//  Copyright (c) 2014 David Olesch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DOImmersiveFormViewController : UIViewController

- (id)initWithTitle:(NSString *)title Questions:(NSArray *)questions andCompletionHandler:(void (^)(NSArray *answers))formCompletionHandler;

@end
