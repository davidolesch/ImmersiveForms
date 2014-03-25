//
//  DOFormField.m
//  ImmersiveForms
//
//  Created by David Olesch on 3/25/14.
//  Copyright (c) 2014 David Olesch. All rights reserved.
//

#import "DOFormField.h"

@interface DOFormField ()

@end

@implementation DOFormField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Customize appearance
        self.fieldLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height / 2.0f)];
        [self.fieldLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
        [self.fieldLabel setTextColor:[UIColor whiteColor]];
        self.fieldTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, frame.size.height / 2.0f, frame.size.width, frame.size.height / 2.0f)];
        [self.fieldTextField setTextAlignment:NSTextAlignmentCenter];
        [self.fieldLabel setTextAlignment:NSTextAlignmentCenter];
        
        // Add  the label and textfield
        [self addSubview:self.fieldLabel];
        [self addSubview:self.fieldTextField];
    }
    return self;
}

@end
