//
//  TopicsListViewController.m
//  Photos
//
//  Created by Ryan Gomba on 10/4/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "TopicsListViewController.h"

#import "TopicsDataSource.h"
#import "TopicCell.h"
#import "TopicViewController.h"
#import "UICollectionView+DataSourceUpdate.h"

static CGFloat const kCellSpacing = 1.0;

static NSString * const kTopicCellReuseID = @"topic-cell";

@interface TopicsListViewController ()<DataSourceDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readwrite) TabBarItem *barItem;

@property (nonatomic, strong) TopicsDataSource *dataSource;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation TopicsListViewController

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
        _barItem.title = @"Topics";
        _barItem.imageName = @"topicGlyph";
    }
    return _barItem;
}

- (TopicsDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [[TopicsDataSource alloc] init];
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
        
        [_collectionView registerClass:[TopicCell class] forCellWithReuseIdentifier:kTopicCellReuseID];
    }
    return _collectionView;
}


#pragma mark -
#pragma mark Helpers

- (Topic *)topicAtIndexPath:(NSIndexPath *)indexPath {
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
    TopicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTopicCellReuseID forIndexPath:indexPath];
    cell.topic = [self topicAtIndexPath:indexPath];
    return cell;
}


#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kCellSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kCellSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellSize = (collectionView.bounds.size.width - kCellSpacing) / 2;
    return CGSizeMake(cellSize, cellSize);
}


#pragma mark -
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Topic *topic = [self topicAtIndexPath:indexPath];
    TopicViewController *topicVC = [[TopicViewController alloc] initWithTopic:topic];
    [self presentViewController:topicVC animated:YES completion:nil];
}


#pragma mark -
#pragma mark PhotosDataSourceDelegate

- (void)dataSource:(DataSource *)dataSource didUpdateObjects:(DataSourceUpdate *)update {
    [self.collectionView performDataSourceUpdate:update animated:YES];
}

@end
