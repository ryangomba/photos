//
//  Database.m
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "Database.h"

#import <YapDatabase/YapDatabase.h>

@implementation Database

+ (YapDatabase *)database {
    static YapDatabase *database;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *applicationSupportDirectory = [paths firstObject];
        NSString *databasePath = [applicationSupportDirectory stringByAppendingString:@"database.sqlite"];
        database = [[YapDatabase alloc] initWithPath:databasePath];
    });
    return database;
}

+ (YapDatabaseConnection *)writeConnection {
    static YapDatabaseConnection *connection;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connection = [[self database] newConnection];
    });
    return connection;
}

+ (void)wipeDatabase {
    [self.writeConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInAllCollections];
    }];
}

+ (void)removeDupes {
    [self.writeConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSMutableSet *set = [NSMutableSet set];
        [transaction enumerateKeysAndObjectsInAllCollectionsUsingBlock:^(NSString *collection, NSString *key, id object, BOOL *stop) {
            if ([object isKindOfClass:[Photo class]]) {
                Photo *photo = object;
                if ([set containsObject:photo.localIdentifier]) {
                    NSLog(@"Duplicate!");
                } else {
                    [set addObject:photo.localIdentifier];
                }
            }
        }];
    }];
}

+ (void)checkForPhotosWithLocalIdentifiers:(NSSet *)localIdentifiers
                                completion:(void (^)(NSSet *))completion {
    
    NSMutableSet *foundLocalIdentifiers = [[NSMutableSet alloc] init];
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction enumerateKeysInAllCollectionsUsingBlock:^(NSString *collection, NSString *key, BOOL *stop) {
            if ([localIdentifiers containsObject:key]) {
                [foundLocalIdentifiers addObject:key];
            }
        }];
    } completionBlock:^{
        completion(foundLocalIdentifiers);
    }];
}

+ (void)savePhotos:(NSArray *)photos completion:(void (^)(void))completion {
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for (Photo *photo in photos) {
            NSString *collectionPK = photo.collectionPK ?: kPhotosCollectionKey;
            [transaction setObject:photo forKey:photo.localIdentifier inCollection:collectionPK];
        }
    } completionBlock:^{
        if (completion) {
            completion();
        }
    }];
}

+ (void)deletePhotos:(NSArray *)photos completion:(void(^)(void))completion {
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for (Photo *photo in photos) {
            NSString *collectionPK = photo.collectionPK ?: kPhotosCollectionKey;
            [transaction removeObjectForKey:photo.localIdentifier inCollection:collectionPK];
        }
    } completionBlock:^{
        if (completion) {
            completion();
        }
    }];
}

+ (void)saveEvents:(NSArray *)events completion:(void (^)(void))completion {
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for (Event *event in events) {
            [transaction setObject:event forKey:event.pk inCollection:kEventsCollectionKey];
        }
    } completionBlock:^{
        if (completion) {
            completion();
        }
    }];
}

+ (void)saveTopics:(NSArray *)topics completion:(void (^)(void))completion {
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for (Topic *topic in topics) {
            [transaction setObject:topic forKey:topic.pk inCollection:kTopicsCollectionKey];
        }
    } completionBlock:^{
        if (completion) {
            completion();
        }
    }];
}

+ (void)addPhotos:(NSArray *)photos toExistingEvent:(Event *)event completion:(void (^)(void))completion {
    [self addPhotos:photos toEvent:event completion:completion];
}

+ (void)addPhotos:(NSArray *)photos toNewEventNamed:(NSString *)eventName completion:(void (^)(void))completion {
    Event *newEvent = [[Event alloc] init];
    newEvent.pk = [NSUUID UUID].UUIDString;
    newEvent.title = eventName;
    [self addPhotos:photos toEvent:newEvent completion:completion];
}

+ (void)addPhotos:(NSArray *)photos toEvent:(Event *)event completion:(void (^)(void))completion {
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        Event *validEvent = [transaction objectForKey:event.pk inCollection:kEventsCollectionKey] ?: event;
        for (Photo *photo in photos) {
            NSString *currentCollectionPK = photo.collectionPK ?: kPhotosCollectionKey;
            [transaction removeObjectForKey:photo.localIdentifier inCollection:currentCollectionPK];
            [transaction setObject:photo forKey:photo.localIdentifier inCollection:event.pk];
            photo.collectionPK = event.pk;
            if (photo.creationDate == [photo.creationDate earlierDate:validEvent.representativeDate]) {
                validEvent.representativeDate = photo.creationDate;
                validEvent.representativePhotoPK = photo.localIdentifier;
            }
        }
        [transaction setObject:validEvent forKey:event.pk inCollection:kEventsCollectionKey];
        
    } completionBlock:^{
        if (completion) {
            completion();
        }
    }];
}

+ (void)addPhotos:(NSArray *)photos toExistingTopic:(Topic *)topic completion:(void (^)(void))completion {
    [self addPhotos:photos toTopic:topic completion:completion];
}

+ (void)addPhotos:(NSArray *)photos toNewTopicNamed:(NSString *)topicName completion:(void (^)(void))completion {
    Topic *newTopic = [[Topic alloc] init];
    newTopic.pk = [NSUUID UUID].UUIDString;
    newTopic.title = topicName;
    [self addPhotos:photos toTopic:newTopic completion:completion];
}

+ (void)addPhotos:(NSArray *)photos toTopic:(Topic *)topic completion:(void (^)(void))completion {
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [self addPhotos:photos toTopic:topic usingTransaction:transaction];
        
    } completionBlock:^{
        if (completion) {
            completion();
        }
    }];
}

+ (void)addPhotos:(NSArray *)photos
          toTopic:(Topic *)topic
 usingTransaction:(YapDatabaseReadWriteTransaction *)transaction {

    Topic *validTopic = [transaction objectForKey:topic.pk inCollection:kTopicsCollectionKey] ?: topic;
    validTopic.representativeDate = [NSDate date];
    for (Photo *photo in photos) {
        NSString *currentCollectionPK = photo.collectionPK ?: kPhotosCollectionKey;
        [transaction removeObjectForKey:photo.localIdentifier inCollection:currentCollectionPK];
        photo.collectionPK = topic.pk;
        [transaction setObject:photo forKey:photo.localIdentifier inCollection:topic.pk];
    }
    if (!validTopic.representativePhotoPK) {
        validTopic.representativePhotoPK = ((Photo *)photos.firstObject).localIdentifier;
    }
    [transaction setObject:validTopic forKey:topic.pk inCollection:kTopicsCollectionKey];
}

+ (void)addPhotos:(NSArray *)photos toScreenshotTopicWithCompletion:(void(^)(void))completion {
    if (photos.count == 0) {
        return;
    }
    
    __block Topic *screenshotTopic;
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        screenshotTopic = [transaction objectForKey:@"screenshots" inCollection:kTopicsCollectionKey];
        if (!screenshotTopic) {
            screenshotTopic = [[Topic alloc] init];
            screenshotTopic.pk = @"screenshots";
            screenshotTopic.title = @"screenshots";
            [transaction setObject:screenshotTopic forKey:screenshotTopic.pk inCollection:kTopicsCollectionKey];
        }
        [self addPhotos:photos toTopic:screenshotTopic usingTransaction:transaction];
        
    } completionBlock:^{
        if (completion) {
            completion();
        }
    }];
}

+ (NSString *)collectionKeyForCollectionType:(CollectionType)collectionType {
    switch (collectionType) {
        case CollectionTypeEvent:
            return kEventsCollectionKey;
        case CollectionTypeTopic:
            return kTopicsCollectionKey;
    }
}

+ (void)fetchRepresentativePhotoForCollectionPK:(NSString *)collectionPK
                                 collectionType:(CollectionType)collectionType
                                     completion:(void(^)(NSObject<Collection> *, Photo *photo))completion {
    
    __block Photo *photo = nil;
    __block NSObject<Collection> *collection = nil;
    [self.database.newConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSString *collectionKey = [self collectionKeyForCollectionType:collectionType];
        collection = [transaction objectForKey:collectionPK inCollection:collectionKey];
        photo = [transaction objectForKey:collection.representativePhotoPK inCollection:collection.pk];
        if (!photo) {
            // TODO reassign
            [transaction enumerateKeysAndObjectsInCollection:collectionPK usingBlock:^(NSString *key, id object, BOOL *stop) {
                photo = object;
            }];
            collection.representativePhotoPK = photo.localIdentifier;
        }
        NSAssert(photo, @"WTF no photo");
        
    } completionBlock:^{
        completion(collection, photo);
    }];
}

@end
