//
//  PhotoImporter.h
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAsset;
@interface PhotoImporter : NSObject

+ (instancetype)sharedPhotoImporter;

- (void)importPhotos;

- (PHAsset *)assetForPhotoWithLocalIdentifier:(NSString *)localIdentifier;

@end
