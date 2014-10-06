//
//  EventsListViewController.m
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "EventsListViewController.h"

#import "EventsDataSource.h"
#import "EventCell.h"
#import "EventViewController.h"
#import "UICollectionView+DataSourceUpdate.h"

static CGFloat const kCellHeight = 140.0;
static CGFloat const kCellSpacing = 2.0;

static NSString * const kEventCellReuseID = @"event-cell";

@interface EventsListViewController ()<DataSourceDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readwrite) TabBarItem *barItem;

@property (nonatomic, strong) EventsDataSource *dataSource;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation EventsListViewController

#pragma mark -
#pragma mark NSObject

- (instancetype)init {
    if (self = [super init]) {
        //
    }
    return self;
}


#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView.frame = self.view.bounds;
    [self.view addSubview:self.collectionView];
    
    self.dataSource.delegate = self;
}


#pragma mark -
#pragma mark Properties

- (TabBarItem *)barItem {
    if (!_barItem) {
        _barItem = [[TabBarItem alloc] init];
        _barItem.title = @"Events";
        _barItem.imageName = @"eventGlyph";
    }
    return _barItem;
}

- (EventsDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [[EventsDataSource alloc] init];
    }
    return _dataSource;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _layout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[EventCell class] forCellWithReuseIdentifier:kEventCellReuseID];
    }
    return _collectionView;
}


#pragma mark -
#pragma mark Helpers

- (Event *)eventAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource objectAtIndexPath:indexPath];
}


#pragma mark -
#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.dataSource numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kEventCellReuseID forIndexPath:indexPath];
    cell.event = [self eventAtIndexPath:indexPath];
    return cell;
}


#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kCellSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, kCellHeight);
}


#pragma mark -
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Event *event = [self eventAtIndexPath:indexPath];
    EventViewController *eventVC = [[EventViewController alloc] initWithEvent:event];
    [self presentViewController:eventVC animated:YES completion:nil];
}


#pragma mark -
#pragma mark PhotosDataSourceDelegate

- (void)dataSource:(DataSource *)dataSource didUpdateObjects:(DataSourceUpdate *)update {
    [self.collectionView performDataSourceUpdate:update animated:YES];
}

@end
