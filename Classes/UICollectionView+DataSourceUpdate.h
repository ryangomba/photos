//
//  UICollectionView+DataSourceUpdate.h
//  Photos
//
//  Created by Ryan Gomba on 10/6/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataSourceUpdate.h"

@interface UICollectionView (DataSourceUpdate)

- (void)performDataSourceUpdate:(DataSourceUpdate *)update animated:(BOOL)animated;

@end
