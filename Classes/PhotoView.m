//
//  PhotoView.m
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "PhotoView.h"

#import <RGFoundation/RGGeometry.h>
#import "PhotoLoader.h"

@interface PhotoView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PhotoLoader *photoLoader;

@end

@implementation PhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView.frame = self.bounds;
        [self addSubview:self.imageView];
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

- (void)setPhoto:(Photo *)photo {
    _photo = photo;
    _photoLoader = [[PhotoLoader alloc] initWithPhoto:photo];
    
    self.imageView.image = nil;
    
    CGSize imageSize = CGSizeMultiply(self.imageView.bounds.size, [UIScreen mainScreen].scale);
    [self.photoLoader loadImageOfSize:imageSize completion:^(UIImage *image, Photo *photo) {
        if ([photo isEqual:self.photo]) {
            self.imageView.image = image;
        }
    }];
}

@end
