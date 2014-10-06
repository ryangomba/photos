//
//  Photo.m
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "Photo.h"

static NSString * const kLocalIdentifierKey = @"localIdentifier";
static NSString * const kCreationDateKey = @"creationDate";
static NSString * const kCollectionPKKey = @"collectionPK";

@implementation Photo

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.localIdentifier = [aDecoder decodeObjectForKey:kLocalIdentifierKey];
        self.creationDate = [aDecoder decodeObjectForKey:kCreationDateKey];
        self.collectionPK = [aDecoder decodeObjectForKey:kCollectionPKKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.localIdentifier forKey:kLocalIdentifierKey];
    [aCoder encodeObject:self.creationDate forKey:kCreationDateKey];
    [aCoder encodeObject:self.collectionPK forKey:kCollectionPKKey];
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
    return [((Photo *)object).localIdentifier isEqualToString:self.localIdentifier];
}

- (NSUInteger)hash {
    return self.localIdentifier.hash;
}

@end
