//
//  Database.h
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kPhotosCollectionKey = @"photos";
static NSString * const kEventsCollectionKey = @"events";
static NSString * const kTopicsCollectionKey = @"topics";

#import "Photo.h"
#import "Event.h"
#import "Topic.h"

@class YapDatabase;

@interface Database : NSObject

+ (YapDatabase *)database;

+ (void)wipeDatabase;

+ (void)removeDupes;

+ (void)checkForPhotosWithLocalIdentifiers:(NSSet *)localIdentifiers
                                completion:(void(^)(NSSet *foundLocalIdentifiers))completion;

+ (void)savePhotos:(NSArray *)photos completion:(void(^)(void))completion;
+ (void)deletePhotos:(NSArray *)photos completion:(void(^)(void))completion;

+ (void)saveEvents:(NSArray *)events completion:(void(^)(void))completion;
+ (void)saveTopics:(NSArray *)topics completion:(void(^)(void))completion;

+ (void)addPhotos:(NSArray *)photos toExistingEvent:(Event *)event completion:(void(^)(void))completion;
+ (void)addPhotos:(NSArray *)photos toNewEventNamed:(NSString *)eventName completion:(void(^)(void))completion;

+ (void)addPhotos:(NSArray *)photos toExistingTopic:(Topic *)topic completion:(void(^)(void))completion;
+ (void)addPhotos:(NSArray *)photos toNewTopicNamed:(NSString *)topicName completion:(void(^)(void))completion;

// TODO messy
+ (void)addPhotos:(NSArray *)photos toScreenshotTopicWithCompletion:(void(^)(void))completion;

+ (void)fetchRepresentativePhotoForCollectionPK:(NSString *)collectionPK
                                 collectionType:(CollectionType)collectionType
                                     completion:(void(^)(NSObject<Collection> *, Photo *photo))completion;

@end
