//
//  TabBarItemView.m
//  Photos
//
//  Created by Ryan Gomba on 10/5/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "TabBarItemView.h"

#import <RGCore/RGMacros.h>
#import <RGFoundation/RGGeometry.h>
#import <RGFoundation/NSObject+KVO.h>

@interface TabBarItemView ()

@property (nonatomic, strong) TabBarItem *tabBarItem;

@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) RGKVOHandle *badgeCountObserver;

@end

@implementation TabBarItemView

- (void)dealloc {
    [self.badgeCountObserver stopObserving];
}

- (instancetype)initWithTabBarItem:(TabBarItem *)tabBarItem {
    if (self = [super initWithFrame:CGRectZero]) {
        self.tabBarItem = tabBarItem;
 
        [self addSubview:self.button];
        [self addSubview:self.badgeLabel];
        
        weakify(self);
        self.badgeCountObserver = [RGObserver(tabBarItem, badgeCount) observeOnMain:^(NSDictionary *change) {
            strongify(self);
            NSInteger badgeCount = [change[NSKeyValueChangeNewKey] integerValue];
            [self updateBadgeCount:badgeCount];
        } options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew];
    }
    return self;
}

- (UILabel *)badgeLabel {
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.backgroundColor = [UIColor redColor];
        _badgeLabel.textColor = [UIColor whiteColor];
    }
    return _badgeLabel;
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] initWithFrame:CGRectZero];
        _button.imageView.contentMode = UIViewContentModeCenter;
        [_button setImage:[UIImage imageNamed:self.tabBarItem.imageName] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    
    self.alpha = selected ? 1.0 : 0.25;
}

- (void)updateBadgeCount:(NSInteger)badgeCount {
    if (badgeCount > 0) {
        self.badgeLabel.hidden = NO;
        self.badgeLabel.text = [NSString stringWithFormat:@"%lu", (long)badgeCount];
        CGSize desiredSize = [self.badgeLabel sizeThatFits:CGSizeMake(FLT_MAX, FLT_MAX)];
        desiredSize.width = MAX(desiredSize.width, desiredSize.height);
        self.badgeLabel.frame = CGRectMake(0.0, 0.0, desiredSize.width, desiredSize.height);
        self.badgeLabel.layer.cornerRadius = desiredSize.height / 2.0;
        self.badgeLabel.layer.masksToBounds = YES;
        [self setNeedsLayout];
        
    } else {
        self.badgeLabel.hidden = YES;
    }
}

- (void)onTap {
    [self.delegate tabBarItemViewDidRecieveTap:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.button.frame = self.bounds;
    
    CGPoint center = CGRectGetMiddle(self.bounds);
    self.badgeLabel.center = CGPointOffset(center, CGPointMake(12.0, -12.0));
}

@end
