//
//  EventsDataSource.m
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "EventsDataSource.h"

#import "Database.h"

@implementation EventsDataSource

- (instancetype)init {
    return [super initWithCollectionKey:kEventsCollectionKey comparator:^NSComparisonResult(Event *event1, Event *event2) {
        return [event2.representativeDate compare:event1.representativeDate];
    } groupingBlock:nil];
}

@end
