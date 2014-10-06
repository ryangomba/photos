//
//  PhotoCell.m
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "PhotoCell.h"

#import "PhotoView.h"
#import <RGInterfaceKit/RGColors.h>

@interface PhotoCell ()

@property (nonatomic, strong) PhotoView *photoView;
@property (nonatomic, strong) UIView *selectionView;

@end

@implementation PhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self =  [super initWithFrame:frame]) {
        self.photoView.frame = self.contentView.bounds;
        [self.contentView addSubview:self.photoView];
        
        self.selectionView.frame = self.contentView.bounds;
        [self.contentView addSubview:self.selectionView];
        
        self.selectionView.hidden = YES;
    }
    return self;
}

- (PhotoView *)photoView {
    if (!_photoView) {
        _photoView = [[PhotoView alloc] initWithFrame:CGRectZero];
        _photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _photoView;
}

- (UIView *)selectionView {
    if (!_selectionView) {
        _selectionView = [[UIView alloc] initWithFrame:CGRectZero];
        _selectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _selectionView.backgroundColor = BLACK_COLOR(0.5);
    }
    return _selectionView;
}

- (Photo *)photo {
    return self.photoView.photo;
}

- (void)setPhoto:(Photo *)photo {
    self.photoView.photo = photo;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.selectionView.hidden = !selected;
}

@end
