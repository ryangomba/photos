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
        [transaction setObject:photo forKey:photo.localIdentifier inCollection:topic.pk];
    }
    if (!validTopic.representativePhotoPK) {
        validTopic.representativePhotoPK = ((Photo *)photos.firstObject).localIdentifier;
    }
    [transaction setObject:validTopic forKey:topic.pk inCollection:kTopicsCollectionKey];
}

+ (void)addPhotos:(NSArray *)photos toScreenshotTopicWithcompletion:(void(^)(void))completion {
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

+ (void)fetchRepresentativePhotoForEvent:(Event *)event completion:(void(^)(Event *event, Photo *photo))completion {
    __block Photo *photo = nil;
    [self.database.newConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        photo = [transaction objectForKey:event.representativePhotoPK inCollection:event.pk];
        NSAssert(photo, @"WTF no photo");
    } completionBlock:^{
        completion(event, photo);
    }];
}

+ (void)fetchRepresentativePhotoForTopic:(Topic *)topic completion:(void(^)(Topic *topic, Photo *photo))completion {
    __block Photo *photo = nil;
    [self.database.newConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        photo = [transaction objectForKey:topic.representativePhotoPK inCollection:topic.pk];
        NSAssert(photo, @"WTF no photo");
    } completionBlock:^{
        completion(topic, photo);
    }];
}

@end
