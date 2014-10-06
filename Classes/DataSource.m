//
//  DataSource.m
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "DataSource.h"

#import <RGCore/RGMacros.h>
#import <RGCore/RGLog.h>
#import <YapDatabase/YapDatabase.h>
#import <YapDatabase/YapDatabaseView.h>
#import "Database.h"

@interface DataSource ()

@property (nonatomic, strong) NSString *viewName;
@property (nonatomic, strong) NSString *collectionKey;
@property (nonatomic, strong) NSComparator comparator;

@property (nonatomic, strong) YapDatabaseConnection *connection;
@property (nonatomic, strong) YapDatabaseView *view;
@property (nonatomic, strong) YapDatabaseViewMappings *mappings;

@end

@implementation DataSource

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    YapDatabase *database = [Database database];
    [database unregisterExtensionWithName:self.viewName];
}

- (instancetype)initWithCollectionKey:(NSString *)collectionKey comparator:(NSComparator)comparator {
    if (self = [super init]) {
        self.collectionKey = collectionKey;
        self.comparator = comparator;
        self.viewName = collectionKey; // TODO hack
        
        YapDatabase *database = [Database database];
        [database registerExtension:self.view withName:self.viewName]; // TODO hack
        self.connection = [database newConnection];
        [self.connection beginLongLivedReadTransaction];
        
        self.mappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[@"default_group"] view:self.viewName];;
        [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction){
            [self.mappings updateWithTransaction:transaction];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDatabaseModified:)
                                                     name:YapDatabaseModifiedNotification
                                                   object:database];
    }
    return self;
}

- (YapDatabaseView *)view {
    if (!_view) {
        YapDatabaseViewGroupingWithKeyBlock groupingBlock =
        ^(NSString *collection, NSString *key) {
            if ([collection isEqualToString:self.collectionKey]) {
                return @"default_group"; // TODO hack
            }
            return (NSString *)nil;
        };
        
        YapDatabaseViewSortingWithObjectBlock sortingBlock =
        ^(NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
            return self.comparator(object1, object2);
        };
        
        _view = [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock
                                             groupingBlockType:YapDatabaseViewBlockTypeWithKey
                                                  sortingBlock:sortingBlock
                                              sortingBlockType:YapDatabaseViewBlockTypeWithObject
                                                    versionTag:@"1.0"
                                                       options:nil];
    }
    return _view;
}

- (void)onDatabaseModified:(NSNotification *)notification {
    NSArray *notifications = [self.connection beginLongLivedReadTransaction];

    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    [[self.connection extension:self.viewName] getSectionChanges:&sectionChanges
                                                      rowChanges:&rowChanges
                                                forNotifications:notifications
                                                    withMappings:self.mappings];
    
    if (sectionChanges.count == 0 && rowChanges.count == 0) {
        return;
    }
    
    DataSourceUpdate *update = [[DataSourceUpdate alloc] init];

    NSMutableIndexSet *deletedSections = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *insertedSections = [NSMutableIndexSet indexSet];
    for (YapDatabaseViewSectionChange *sectionChange in sectionChanges) {
        switch (sectionChange.type) {
            case YapDatabaseViewChangeDelete:
                [deletedSections addIndex:sectionChange.index];
                break;
            case YapDatabaseViewChangeInsert:
                [insertedSections addIndex:sectionChange.index];
            default:
                break;
        }
    }
    update.deletedSections = deletedSections;
    update.insertedSections = insertedSections;
    
    NSMutableArray *deletedIndexPaths = [NSMutableArray array];
    NSMutableArray *insertedIndexPaths = [NSMutableArray array];
    NSMutableArray *updatedIndexPaths = [NSMutableArray array];
    for (YapDatabaseViewRowChange *rowChange in rowChanges) {
        switch (rowChange.type) {
            case YapDatabaseViewChangeDelete:
                [deletedIndexPaths addObject:rowChange.indexPath];
                break;
            case YapDatabaseViewChangeInsert:
                [insertedIndexPaths addObject:rowChange.newIndexPath];
                break;
            case YapDatabaseViewChangeMove:
                [deletedIndexPaths addObject:rowChange.indexPath];
                [insertedIndexPaths addObject:rowChange.newIndexPath];
                break;
            case YapDatabaseViewChangeUpdate:
                [updatedIndexPaths addObject:rowChange.indexPath];
                break;
        }
    }
    update.deletedIndexPaths = deletedIndexPaths;
    update.insertedIndexPaths = insertedIndexPaths;
    update.updatedIndexPaths = updatedIndexPaths;
    
    [self.delegate dataSource:self didUpdateObjects:update];
}

- (NSInteger)numberOfSections {
    return self.mappings.numberOfSections;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return [self.mappings numberOfItemsInSection:section];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    __block id object;
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        YapDatabaseViewTransaction *viewTransaction = [transaction extension:self.viewName];
        object = [viewTransaction objectAtIndex:indexPath.item inGroup:@"default_group"];
    }];
    return object;
}

@end
