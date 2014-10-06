//
//  DataSource.h
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataSourceUpdate.h"

@class DataSource;
@protocol DataSourceDelegate<NSObject>

- (void)dataSource:(DataSource *)dataSource didUpdateObjects:(DataSourceUpdate *)update;

@end

@interface DataSource : NSObject

- (instancetype)initWithCollectionKey:(NSString *)collectionKey
                           comparator:(NSComparator)comparator
                        groupingBlock:(NSString * (^)(id object))groupingBlock;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)titleForSection:(NSInteger)section;

@property (nonatomic, weak) id<DataSourceDelegate> delegate;

@end
