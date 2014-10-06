//
//  PhotosListViewController.h
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotosDataSource.h"

@interface PhotosListViewController : UIViewController<DataSourceDelegate>

@property (nonatomic, strong, readonly) PhotosDataSource *dataSource; // HACK

- (instancetype)initWithDataSource:(PhotosDataSource *)dataSource;

@end
