// Copyright 2014-present Ryan Gomba. All Rights Reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataSourceUpdate : NSObject

@property (nonatomic, strong) NSIndexSet *deletedSections;
@property (nonatomic, strong) NSIndexSet *insertedSections;

@property (nonatomic, strong) NSArray *deletedIndexPaths;
@property (nonatomic, strong) NSArray *insertedIndexPaths;
@property (nonatomic, strong) NSArray *updatedIndexPaths;

@end
