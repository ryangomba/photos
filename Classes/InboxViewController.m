//  Copyright 2014-present Ryan Gomba. All rights reserved.

#import "InboxViewController.h"

#import "Database.h"

@interface InboxViewController ()

@property (nonatomic, strong, readwrite) TabBarItem *barItem;

@end

@implementation InboxViewController

- (instancetype)init {
    PhotosDataSource *dataSource = [[PhotosDataSource alloc] initWithCollectionKey:kPhotosCollectionKey];
    if (self = [super initWithDataSource:dataSource]) {
        //
    }
    return self;
}

- (TabBarItem *)barItem {
    if (!_barItem) {
        _barItem = [[TabBarItem alloc] init];
        _barItem.title = @"Inbox";
        _barItem.imageName = @"inboxGlyph";
    }
    return _barItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateBadgeCount];
}

- (void)dataSource:(DataSource *)dataSource didUpdateObjects:(DataSourceUpdate *)update {
    [super dataSource:dataSource didUpdateObjects:update];
    
    [self updateBadgeCount];
}

- (void)updateBadgeCount {
    self.barItem.badgeCount = [self.dataSource numberOfItemsInSection:0]; // HACK
}

@end
