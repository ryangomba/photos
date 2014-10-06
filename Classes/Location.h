//
//  Location.m
//  Photos
//
//  Created by Ryan Gomba on 10/6/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

@interface Location : NSObject<NSCoding>

@property (nonatomic, assign, readonly) double latitude;
@property (nonatomic, assign, readonly) double longitude;

- (instancetype)initWithLocation:(CLLocation *)location;
- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude;

- (CLLocation *)location;

@end
