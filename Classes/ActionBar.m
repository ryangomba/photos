//
//  ActionBar.m
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "ActionBar.h"

#import <RGInterfaceKit/RGColors.h>

@interface ActionBar ()

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *eventButton;
@property (nonatomic, strong) UIButton *topicButton;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation ActionBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = HEX_COLOR(0x222222);
        for (UIButton *button in self.buttons) {
            [self addSubview:button];
        }
    }
    return self;
}

- (UIButton *)newButtonWithImageNamed:(NSString *)imageName {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [self newButtonWithImageNamed:@"cancelGlyph"];
    }
    return _cancelButton;
}

- (UIButton *)eventButton {
    if (!_eventButton) {
        _eventButton = [self newButtonWithImageNamed:@"eventGlyph"];
    }
    return _eventButton;
}

- (UIButton *)topicButton {
    if (!_topicButton) {
        _topicButton = [self newButtonWithImageNamed:@"topicGlyph"];
    }
    return _topicButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [self newButtonWithImageNamed:@"deleteGlyph"];
    }
    return _deleteButton;
}

- (void)onButtonTapped:(UIButton *)button {
    if (button == self.cancelButton) {
        [self.delegate actionBarDidSelectCancel:self];
    } else if (button == self.eventButton) {
        [self.delegate actionBarDidSelectEvent:self];
    } else if (button == self.topicButton) {
        [self.delegate actionBarDidSelectTopic:self];
    } else if (button == self.deleteButton) {
        [self.delegate actionBarDidSelectDelete:self];
    }
}

- (NSArray *)buttons {
    return @[
        self.cancelButton,
        self.eventButton,
        self.topicButton,
        self.deleteButton
    ];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger buttonWidth = self.bounds.size.width / 4;
    [self.buttons enumerateObjectsUsingBlock:
     ^(UIButton *button, NSUInteger i, BOOL *stop) {
         NSInteger x = buttonWidth * i;
         button.frame = CGRectMake(x, 0.0, buttonWidth, self.bounds.size.height);
    }];
}

@end
