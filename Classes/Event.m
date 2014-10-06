//
//  Event.m
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "Event.h"

static NSString * const kPKKey = @"pk";
static NSString * const kTitleKey = @"title";
static NSString * const kRepresentativeDateKey = @"representativeDate";
static NSString * const kRepresentativePhotoPKKey = @"representativePhotoPK";

@implementation Event

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.pk = [aDecoder decodeObjectForKey:kPKKey];
        self.title = [aDecoder decodeObjectForKey:kTitleKey];
        self.representativeDate = [aDecoder decodeObjectForKey:kRepresentativeDateKey];
        self.representativePhotoPK = [aDecoder decodeObjectForKey:kRepresentativePhotoPKKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pk forKey:kPKKey];
    [aCoder encodeObject:self.title forKey:kTitleKey];
    [aCoder encodeObject:self.representativeDate forKey:kRepresentativeDateKey];
    [aCoder encodeObject:self.representativePhotoPK forKey:kRepresentativePhotoPKKey];
}


#pragma mark -
#pragma mark Equality

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    return [((Event *)object).pk isEqualToString:self.pk];
}

- (NSUInteger)hash {
    return self.pk.hash;
}

@end
