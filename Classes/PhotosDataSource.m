//
//  PhotosDataSource.m
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "PhotosDataSource.h"

#import "Photo.h"

@implementation PhotosDataSource

- (instancetype)initWithCollectionKey:(NSString *)collectionKey {
    return [super initWithCollectionKey:collectionKey comparator:^NSComparisonResult(Photo *photo1, Photo *photo2) {
        return [photo1.creationDate compare:photo2.creationDate];
    }];
}

@end
