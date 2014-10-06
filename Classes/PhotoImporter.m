//
//  PhotoImporter.m
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "PhotoImporter.h"

@import Photos;
#import <RGFoundation/NSSet+Additions.h>

#import "Database.h"
#import "ScreenshotIndex.h"

@interface PhotoImporter ()<PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) NSDictionary *assetsMap;
@property (nonatomic, assign) BOOL isImporting;
@property (nonatomic, assign) BOOL needsImport;

@end

@implementation PhotoImporter

+ (instancetype)sharedPhotoImporter {
    static id sharedPhotoImporter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPhotoImporter = [[self alloc] init];
    });
    return sharedPhotoImporter;
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    return self;
}

- (void)importPhotos {
    NSAssert([NSThread isMainThread], @"Import on the main thread only");
    
    if (self.isImporting) {
        self.needsImport = YES;
        return;
    }
    
    self.needsImport = NO;
    
    NSMutableDictionary *assetsMap = [NSMutableDictionary dictionary];
    NSMutableArray *allAssets = [NSMutableArray array];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.includeAllBurstAssets = NO;
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithOptions:options];
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger i, BOOL *stop) {
        [allAssets addObject:asset];
        assetsMap[asset.localIdentifier] = asset;
    }];
    self.assetsMap = assetsMap;
    
    NSMutableArray *assetsToImport = [NSMutableArray array];
    NSSet *localIdentifiers = [NSSet setWithArray:[allAssets valueForKey:@"localIdentifier"]];
    [Database checkForPhotosWithLocalIdentifiers:localIdentifiers completion:^(NSSet *foundLocalIdentifiers) {
        NSSet *newPhotoIdentifiers = [localIdentifiers setBySubtractingSet:foundLocalIdentifiers];
        for (PHAsset *asset in allAssets) {
            if ([newPhotoIdentifiers containsObject:asset.localIdentifier]) {
                [assetsToImport addObject:asset];
            }
        }
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        NSMutableArray *screenshots = [[NSMutableArray alloc] init];
        for (PHAsset *asset in assetsToImport) {
            Photo *photo = [[Photo alloc] init];
            photo.localIdentifier = asset.localIdentifier;
            photo.creationDate = asset.creationDate;
            [photos addObject:photo];
            CGSize imageSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
            if ([ScreenshotIndex imageSizeQualifiesAsScreenshot:imageSize]) {
                [screenshots addObject:photo];
            }
        }
        [Database savePhotos:photos completion:^{
            [Database addPhotos:screenshots toScreenshotTopicWithcompletion:^{
                self.isImporting = NO;
                if (self.needsImport) {
                    [self importPhotos];
                }
            }];
        }];
    }];
}

- (PHAsset *)assetForPhotoWithLocalIdentifier:(NSString *)localIdentifier {
    NSAssert(self.assetsMap, @"Assets not loaded");
    return self.assetsMap[localIdentifier];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self importPhotos];
    });
}


#pragma mark -
#pragma mark Screenshots

- (void)createScreenshotTopicIfNecessaray {
    
}

@end
