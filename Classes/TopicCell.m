//
//  TopicCell.m
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "TopicCell.h"

#import <RGFoundation/RGGeometry.h>
#import <RGInterfaceKit/RGColors.h>
#import "PhotoLoader.h"
#import "Database.h"

@interface TopicCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) PhotoLoader *photoLoader;

@end

@implementation TopicCell

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

- (void)setTopic:(Topic *)topic {
    _topic = topic;
    
    self.imageView.image = nil;
    self.titleLabel.text = [NSString stringWithFormat:@"#%@", topic.title];
    
    // TODO so messy, race conditions for sure
    CGSize imageSize = CGSizeMultiply(self.imageView.bounds.size, [UIScreen mainScreen].scale);
    [Database fetchRepresentativePhotoForTopic:topic completion:^(Topic *topic, Photo *photo) {
        NSAssert(photo, @"No photo");
        if ([topic isEqual:self.topic]) {
            self.photoLoader = [[PhotoLoader alloc] initWithPhoto:photo];
            [self.photoLoader loadImageOfSize:imageSize completion:^(UIImage *image, Photo *photo) {
                if ([topic isEqual:self.topic]) {
                    self.imageView.image = image;
                }
            }];
        }
    }];
}

@end
