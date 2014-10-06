//
//  PhotosListViewController.m
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "PhotosListViewController.h"

#import "PhotoCell.h"
#import "ActionBar.h"
#import "Database.h"
#import "DataSourceUpdate.h"
#import "UICollectionView+DataSourceUpdate.h"

static NSInteger const kNumberOfColumns = 4;
static CGFloat const kCellSpacing = 1.0;
static CGFloat const kSelectionBarHeight = 60.0;

static NSString * const kPhotoCellReuseID = @"photo-cell";

@interface PhotosListViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ActionBarDelegate>

@property (nonatomic, strong, readwrite) PhotosDataSource *dataSource;

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
    
    [self.collectionView layoutIfNeeded];
    CGFloat contentHeight = self.collectionView.contentSize.height + self.collectionView.contentInset.bottom;
    CGFloat collectionViewHeight = self.collectionView.bounds.size.height;
    CGFloat offsetY = MAX(contentHeight - collectionViewHeight, 0.0);
    self.collectionView.contentOffset = CGPointMake(0.0, offsetY);
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
        
        [_collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:kPhotoCellReuseID];
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellReuseID forIndexPath:indexPath];
    cell.photo = [self photoAtIndexPath:indexPath];
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


#pragma mark -
#pragma mark ActionBarDelegate

- (void)actionBarDidSelectCancel:(ActionBar *)actionBar {
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
}

- (void)actionBarDidSelectEvent:(ActionBar *)actionBar {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New Event" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        NSString *eventName = textField.text;
        NSAssert(eventName.length > 0, @"Not a valid event name");
        [Database addPhotos:self.selectedPhotos toNewEventNamed:eventName completion:nil];
    }];
    [alertController addTextFieldWithConfigurationHandler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:addAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)actionBarDidSelectTopic:(ActionBar *)actionBar {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New Topic" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        NSString *topicName = textField.text;
        NSAssert(topicName.length > 0, @"Not a valid topic name");
        [Database addPhotos:self.selectedPhotos toNewTopicNamed:topicName completion:nil];
    }];
    [alertController addTextFieldWithConfigurationHandler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:addAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)actionBarDidSelectDelete:(ActionBar *)actionBar {
    //
}


#pragma mark -
#pragma mark PhotosDataSourceDelegate

- (void)dataSource:(DataSource *)dataSource didUpdateObjects:(DataSourceUpdate *)update {
    [self.collectionView performDataSourceUpdate:update animated:YES];
}

@end
