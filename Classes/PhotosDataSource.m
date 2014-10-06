//
//  PhotosDataSource.m
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "PhotosDataSource.h"

#import "Photo.h"
#import <APTimeZones/APTimeZones.h>

@implementation PhotosDataSource

- (instancetype)initWithCollectionKey:(NSString *)collectionKey {
    return [super initWithCollectionKey:collectionKey comparator:^NSComparisonResult(Photo *photo1, Photo *photo2) {
        return [photo1.creationDate compare:photo2.creationDate];
    } groupingBlock:^(Photo *photo) {
        NSDate *creationDate = photo.creationDate;
        
        // day starts at 4am
        NSTimeInterval fourHours = 60 * 60 * 4;
        NSDate *adjustedDate = [NSDate dateWithTimeInterval:-fourHours sinceDate:creationDate];
        
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSTimeZone *timezone;
        if (photo.location) {
            timezone = [[APTimeZones sharedInstance] timeZoneWithLocation:photo.location.location];
        } else {
            timezone = [NSTimeZone systemTimeZone];
        }
        
        NSDateComponents *components = [calendar componentsInTimeZone:timezone fromDate:adjustedDate];
        NSString *groupKey = [NSString stringWithFormat:@"%04lu-%02lu-%02lu", (long)components.year, (long)components.month, (long)components.day];
        
        return groupKey;
    }];
}

@end
