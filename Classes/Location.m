//
//  Location.m
//  Photos
//
//  Created by Ryan Gomba on 10/6/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "Location.h"

@import CoreLocation;

static NSString * const kLatitudeKey = @"lat";
static NSString * const kLongitudeKey = @"lon";

@interface Location ()

@property (nonatomic, assign, readwrite) double latitude;
@property (nonatomic, assign, readwrite) double longitude;

@end

@implementation Location

- (instancetype)initWithLocation:(CLLocation *)location {
    if (!location) {
        return nil;
    }
    CLLocationCoordinate2D coordinate = location.coordinate;
    return [self initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
}

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude {
    if (self = [super init]) {
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.latitude = [[aDecoder decodeObjectForKey:kLatitudeKey] doubleValue];
        self.longitude = [[aDecoder decodeObjectForKey:kLongitudeKey] doubleValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.latitude) forKey:kLatitudeKey];
    [aCoder encodeObject:@(self.longitude) forKey:kLongitudeKey];
}

- (CLLocation *)location {
    return [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
}

@end
