//
//  PhotosListViewController.m
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "PhotosListViewController.h"

// TODO move out of here
@import Photos;

#import "PhotoCell.h"
#import "ActionBar.h"
#import "Database.h"
#import "DataSourceUpdate.h"
#import "UICollectionView+DataSourceUpdate.h"
#import "CollectionPickerViewController.h"
#import "PhotoSectionHeaderView.h"
#import "EventsDataSource.h"
#import "TopicsDataSource.h"

static NSInteger const kNumberOfColumns = 4;
static CGFloat const kCellSpacing = 1.0;
static CGFloat const kSelectionBarHeight = 60.0;

static NSString * const kPhotoCellReuseID = @"photo-cell";
static NSString * const kPhotoHeaderReuseID = @"photo-header";

@interface PhotosListViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ActionBarDelegate, CollectionPickerViewControllerDelegate, PhotoSectionHeaderViewDelegate>

@property (nonatomic, strong, readwrite) PhotosDataSource *dataSource;
@property (nonatomic, assign) BOOL loadedOnce;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) ActionBar *actionBar;

@end

@implementation PhotosListViewController

#pragma mark -
#pragma mark NSObject

- (instancetype)initWithDataSource:(PhotosDataSource *)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
        self.dataSource.delegate = self;
    }
    return self;
}


#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.frame = self.view.bounds;
    [self.view addSubview:self.collectionView];
    
    CGFloat selectionBarY = self.view.bounds.size.height - kSelectionBarHeight;
    self.actionBar.frame = CGRectMake(0.0, selectionBarY, self.view.bounds.size.width, kSelectionBarHeight);
    [self.view addSubview:self.actionBar];
    
    [self updateSelectionBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.loadedOnce) {
        self.loadedOnce = YES;
        
        [self.collectionView layoutIfNeeded];
        CGFloat contentHeight = self.collectionView.contentSize.height + self.collectionView.contentInset.bottom;
        CGFloat collectionViewHeight = self.collectionView.bounds.size.height;
        CGFloat offsetY = MAX(contentHeight - collectionViewHeight, 0.0);
        self.collectionView.contentOffset = CGPointMake(0.0, offsetY);
    }
}


#pragma mark -
#pragma mark Properties

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _layout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, kSelectionBarHeight, 0.0);
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        [_collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:kPhotoCellReuseID];
        [_collectionView registerClass:[PhotoSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kPhotoHeaderReuseID];
    }
    return _collectionView;
}

- (ActionBar *)actionBar {
    if (!_actionBar) {
        _actionBar = [[ActionBar alloc] initWithFrame:CGRectZero];
        _actionBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _actionBar.delegate = self;
    }
    return _actionBar;
}


#pragma mark -
#pragma mark Helpers

- (Photo *)photoAtIndexPath:(NSIndexPath *)indexPath {
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    PhotoSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kPhotoHeaderReuseID forIndexPath:indexPath];
    NSString *groupName = [self.dataSource titleForSection:indexPath.section];
    header.sectionIndex = indexPath.section;
    header.title = groupName;
    header.delegate = self;
    return header;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellReuseID forIndexPath:indexPath];
    cell.photo = [self photoAtIndexPath:indexPath];
    return cell;
}


#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0, 0.0, 20.0, 0.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kCellSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kCellSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.height, 44.0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat availableWidth = collectionView.bounds.size.width - kCellSpacing * (kNumberOfColumns - 1);
    CGFloat cellSize = availableWidth / kNumberOfColumns;
    return CGSizeMake(cellSize, cellSize);
}


#pragma mark -
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self updateSelectionBar];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self updateSelectionBar];
}


#pragma mark -
#pragma mark Selection

- (void)updateSelectionBar {
    NSInteger selectionCount = [self.collectionView indexPathsForSelectedItems].count;
    self.actionBar.hidden = selectionCount == 0;
}

- (NSArray *)selectedPhotos {
    NSMutableArray *photos = [NSMutableArray array];
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        Photo *photo = [self photoAtIndexPath:indexPath];
        [photos addObject:photo];
    }
    return photos;
}

- (void)deselectSelectedPhotos {
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
    [self updateSelectionBar];
}


#pragma mark -
#pragma mark PhotoSectionHeaderViewDelegate

- (void)photoSectionHeaderViewDidAskForSelection:(PhotoSectionHeaderView *)headerView {
    NSInteger section = headerView.sectionIndex;
    for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:section]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    [self updateSelectionBar];
}


#pragma mark -
#pragma mark ActionBarDelegate

- (void)actionBarDidSelectCancel:(ActionBar *)actionBar {
    [self deselectSelectedPhotos];
}

- (void)actionBarDidSelectEvent:(ActionBar *)actionBar {
    EventsDataSource *dataSource = [[EventsDataSource alloc] init];
    CollectionPickerViewController *picker = [[CollectionPickerViewController alloc] initWithCollectionType:CollectionTypeEvent dataSource:dataSource];
    [self presentViewController:picker animated:YES completion:nil];
    picker.delegate = self;
}

- (void)actionBarDidSelectTopic:(ActionBar *)actionBar {
    TopicsDataSource *dataSource = [[TopicsDataSource alloc] init];
    CollectionPickerViewController *picker = [[CollectionPickerViewController alloc] initWithCollectionType:CollectionTypeTopic dataSource:dataSource];
    [self presentViewController:picker animated:YES completion:nil];
    picker.delegate = self;
}

- (void)actionBarDidSelectDelete:(ActionBar *)actionBar {
    NSArray *selectedPhotos = [self selectedPhotos];
    
    NSMutableArray *assets = [NSMutableArray array];
    NSArray *localIdentifiers = [selectedPhotos valueForKey:@"localIdentifier"];
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:localIdentifiers options:nil];
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger i, BOOL *stop) {
        [assets addObject:asset];
    }];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:assets];
        
    } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            [Database deletePhotos:selectedPhotos completion:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self deselectSelectedPhotos];
            });
        }
    }];
}


#pragma mark -
#pragma mark CollectionPickerViewControllerDelegate

- (void)collectionPickerViewController:(CollectionPickerViewController *)controller
           didCreateNewCollectionNamed:(NSString *)collectionName {
    
    NSArray *selectedPhotos = [self selectedPhotos];
    [self deselectSelectedPhotos];
    
    switch (controller.collectionType) {
        case CollectionTypeEvent: {
            [Database addPhotos:selectedPhotos
                toNewEventNamed:collectionName
                     completion:nil];
        } break;
            
        case CollectionTypeTopic: {
            [Database addPhotos:selectedPhotos
                toNewTopicNamed:collectionName
                     completion:nil];
        } break;
    }

    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)collectionPickerViewController:(CollectionPickerViewController *)controller
           didSelectExistingCollection:(NSObject<Collection> *)collection {

    NSArray *selectedPhotos = [self selectedPhotos];
    [self deselectSelectedPhotos];
    
    switch (controller.collectionType) {
        case CollectionTypeEvent: {
            [Database addPhotos:selectedPhotos
                toExistingEvent:(id)collection
                     completion:nil];
        } break;
            
        case CollectionTypeTopic: {
            [Database addPhotos:selectedPhotos
                toExistingTopic:(id)collection
                     completion:nil];
        } break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark PhotosDataSourceDelegate

- (void)dataSource:(DataSource *)dataSource didUpdateObjects:(DataSourceUpdate *)update {
    [self.collectionView performDataSourceUpdate:update animated:YES];
}

@end
