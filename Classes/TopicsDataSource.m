//
//  TopicsDataSource.m
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "TopicsDataSource.h"

#import "Database.h"

@implementation TopicsDataSource

- (instancetype)init {
    return [super initWithCollectionKey:kTopicsCollectionKey comparator:^NSComparisonResult(Topic *topic1, Topic *topic2) {
        return [topic2.representativeDate compare:topic1.representativeDate];
    } groupingBlock:nil];
}

@end
