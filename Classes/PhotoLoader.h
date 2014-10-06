//
//  PhotoLoader.h
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Photo.h"

@interface PhotoLoader : NSObject

- (instancetype)initWithPhoto:(Photo *)photo;

- (void)loadImageOfSize:(CGSize)imageSize completion:(void(^)(UIImage *image, Photo *photo))completion;

@end
