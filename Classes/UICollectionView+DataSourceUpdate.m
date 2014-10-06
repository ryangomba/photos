//
//  UICollectionView+DataSourceUpdate.m
//  Photos
//
//  Created by Ryan Gomba on 10/6/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "UICollectionView+DataSourceUpdate.h"

@implementation UICollectionView (DataSourceUpdate)

- (void)performDataSourceUpdate:(DataSourceUpdate *)update animated:(BOOL)animated {
    if (!animated) {
        [UIView setAnimationsEnabled:NO];
    }
    [self performBatchUpdates:^{
        [self deleteSections:update.deletedSections];
        [self insertSections:update.insertedSections];
        [self deleteItemsAtIndexPaths:update.deletedIndexPaths];
        [self insertItemsAtIndexPaths:update.insertedIndexPaths];
        [self reloadItemsAtIndexPaths:update.updatedIndexPaths];
        
    } completion:^(BOOL finished) {
        if (!animated) {
            [UIView setAnimationsEnabled:YES];
        }
    }];
}

@end
