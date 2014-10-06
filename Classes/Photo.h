//
//  Photo.h
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Location.h"

@interface Photo : NSObject<NSCoding>

@property (nonatomic, strong) NSString *localIdentifier;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) Location *location;

@property (nonatomic, strong) NSString *collectionPK;

@end
