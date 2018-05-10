//
//  TopicCell.m
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "CollectionCell.h"

#import <RGFoundation/RGGeometry.h>
#import <RGInterfaceKit/RGColors.h>
#import "PhotoLoader.h"
#import "Database.h"

@interface CollectionCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) PhotoLoader *photoLoader;

@end

@implementation CollectionCell

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
        _titleLabel.backgroundColor = ALPHA_COLOR(0x222222, 0.6);
    }
    return _titleLabel;
}

- (void)setCollection:(NSObject<Collection> *)collection {
    _collection = collection;
    
    self.imageView.image = nil;
    self.titleLabel.text = collection.displayName;
    
    // TODO so messy, race conditions for sure
    CGSize imageSize = CGSizeMultiply(self.imageView.bounds.size, [UIScreen mainScreen].scale);
    [Database fetchRepresentativePhotoForCollectionPK:self.collection.pk
                                       collectionType:self.collection.type
                                           completion:^(NSObject<Collection> *collection, Photo *photo)
     {
         NSAssert(photo, @"No photo");
         if ([collection isEqual:self.collection]) {
             self.photoLoader = [[PhotoLoader alloc] initWithPhoto:photo];
             [self.photoLoader loadImageOfSize:imageSize completion:^(UIImage *image, Photo *photo) {
                 if ([collection isEqual:self.collection]) {
                     self.imageView.image = image;
                 }
             }];
         }
    }];
}

@end
