//
//  WelcomView.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/16/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "WelcomView.h"

@interface WelcomView ()

- (void)addTextViewWithFrame:(CGRect)frame;

@end

@implementation WelcomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTextViewWithFrame:frame];
    }
    return self;
}

- (void)addTextViewWithFrame:(CGRect)frame
{
    UITextView *textView = [[UITextView alloc] initWithFrame:frame];
    textView.editable = NO;
    textView.text = @"Click on the Menu to select a store and start shopping!";
    
    [self addSubview:textView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
