//
//  EventCell.m
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "EventCell.h"

#import <RGFoundation/RGGeometry.h>
#import <RGInterfaceKit/RGColors.h>
#import "PhotoLoader.h"
#import "Database.h"

@interface EventCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) PhotoLoader *photoLoader;

@end

@implementation EventCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView.frame = self.contentView.bounds;
        [self.contentView addSubview:self.imageView];
        
        self.titleLabel.frame = self.contentView.bounds;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = ALPHA_COLOR(0x222222, 0.75);
    }
    return _titleLabel;
}

- (void)setEvent:(Event *)event {
    _event = event;
    
    self.imageView.image = nil;
    self.titleLabel.text = event.title;
    
    // TODO so messy, race conditions for sure
    CGSize imageSize = CGSizeMultiply(self.imageView.bounds.size, [UIScreen mainScreen].scale);
    [Database fetchRepresentativePhotoForEvent:event completion:^(Event *event, Photo *photo) {
        if ([event isEqual:self.event]) {
            self.photoLoader = [[PhotoLoader alloc] initWithPhoto:photo];
            [self.photoLoader loadImageOfSize:imageSize completion:^(UIImage *image, Photo *photo) {
                if ([event isEqual:self.event]) {
                    self.imageView.image = image;
                }
            }];
        }
    }];
}

@end
