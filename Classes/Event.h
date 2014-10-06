//
//  Event.h
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject<NSCoding>

@property (nonatomic, strong) NSString *pk;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *representativeDate;

@property (nonatomic, strong) NSString *representativePhotoPK;

@end
