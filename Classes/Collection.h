//
//  Collection.h
//  Photos
//
//  Created by Ryan Gomba on 10/6/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CollectionType) {
    CollectionTypeEvent,
    CollectionTypeTopic,
};

@protocol Collection <NSObject>

@property (nonatomic, readonly) CollectionType type;
@property (nonatomic, readonly) NSString *displayName;

@property (nonatomic, strong) NSString *pk;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *representativeDate;

@property (nonatomic, strong) NSString *representativePhotoPK;

@end
