//
//  PhotoLoader.m
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "PhotoLoader.h"
#import "PhotoImporter.h"

@import Photos;

@interface PhotoLoader ()

@property (nonatomic, strong) Photo *photo;
@property (nonatomic, assign) PHImageRequestID requestID;

@end

@implementation PhotoLoader

- (void)dealloc {
    [self cancelCurrentLoadOperation];
}

- (instancetype)initWithPhoto:(Photo *)photo {
    if (self = [super init]) {
        self.photo = photo;
    }
    return self;
}

- (void)cancelCurrentLoadOperation {
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
    }
}

- (void)loadImageOfSize:(CGSize)imageSize completion:(void (^)(UIImage *, Photo *))completion {
    [self cancelCurrentLoadOperation];
    
    NSString *assetID = self.photo.localIdentifier;
    PHAsset *asset = [[PhotoImporter sharedPhotoImporter] assetForPhotoWithLocalIdentifier:assetID];
    [self doLoadImageOfSize:imageSize forAsset:asset completion:completion];
}

- (void)doLoadImageOfSize:(CGSize)imageSize forAsset:(PHAsset *)asset completion:(void (^)(UIImage *, Photo *))completion {
    NSAssert(self.photo, @"No photo");
    
    Photo *photo = self.photo;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.networkAccessAllowed = YES;
    self.requestID = [[PHImageManager defaultManager] requestImageForAsset:asset
                                                                targetSize:imageSize
                                                               contentMode:PHImageContentModeAspectFill
                                                                   options:options
                                                             resultHandler:^(UIImage *result, NSDictionary *info)
                      {
                          if (!result) {
                              NSLog(@"Sad panda; no image delivered from Apple");
                          }
                          dispatch_async(dispatch_get_main_queue(), ^{
                              completion(result, photo);
                          });
                      }];
}

@end
