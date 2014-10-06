//
//  PhotoSectionHeaderView.m
//  Photos
//
//  Created by Ryan Gomba on 10/6/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "PhotoSectionHeaderView.h"

@interface PhotoSectionHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *selectionButton;

@end

@implementation PhotoSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.selectionButton];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UIButton *)selectionButton {
    if (!_selectionButton) {
        _selectionButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _selectionButton.backgroundColor = [UIColor greenColor];
        [_selectionButton addTarget:self action:@selector(onSelectionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectionButton;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

- (void)onSelectionButtonTapped {
    [self.delegate photoSectionHeaderViewDidAskForSelection:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0.0, 24.0, 0.0, 60.0));
    self.selectionButton.frame = CGRectMake(self.bounds.size.width - 60.0, 0.0, 60.0, self.bounds.size.height);
}

@end
