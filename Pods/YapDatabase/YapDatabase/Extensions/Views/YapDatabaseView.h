#import <Foundation/Foundation.h>

#import "YapDatabaseExtension.h"
#import "YapDatabaseViewTypes.h"
#import "YapDatabaseViewOptions.h"
#import "YapDatabaseViewConnection.h"
#import "YapDatabaseViewTransaction.h"
#import "YapDatabaseViewMappings.h"
#import "YapDatabaseViewChange.h"
#import "YapDatabaseViewRangeOptions.h"

/**
 * Welcome to YapDatabase!
 * 
 * https://github.com/yaptv/YapDatabase
 * 
 * The project wiki has a wealth of documentation if you have any questions.
 * https://github.com/yaptv/YapDatabase/wiki
 *
 * YapDatabaseView is an extension designed to work with YapDatabase.
 * It gives you a persistent sorted "view" of a configurable subset of your data.
 *
 * For the full documentation on Views, please see the related wiki article:
 * https://github.com/yaptv/YapDatabase/wiki/Views
 * 
 * Just in case you don't have Internet access,
 * see the quick overview in YapDatabaseView.h.
**/
@interface YapDatabaseView : YapDatabaseExtension

/* Inherited from YapDatabaseExtension
 
@property (nonatomic, strong, readonly) NSString *registeredName;

*/

/**
 * See the wiki for an example of how to initialize a view:
 * https://github.com/yaptv/YapDatabase/wiki/Views#wiki-initializing_a_view
 *
 * @param groupingBlock
 * 
 *   The grouping block handles both filtering and grouping.
 *   
 *   @see YapDatabaseViewTypes.h for block type definition(s).
 * 
 * @param groupingBlockType
 * 
 *   Specify the type of groupingBlock that is being passed.
 *   
 *   @see YapDatabaseViewTypes.h for block type definition(s).
 * 
 * @param sortingBlock
 * 
 *   The sorting block handles sorting of objects within their group.
 *   
 *   @see YapDatabaseViewTypes.h for block type definition(s).
 * 
 * @param sortingBlockType
 * 
 *   Specify the type of sortingBlock that is being passed.
 *   
 *   @see YapDatabaseViewTypes.h for block type definition(s).
 *
 * @param versionTag
 *
 *   If, after creating a view, you need to change either the groupingBlock or sortingBlock,
 *   then simply use the versionTag parameter. If you pass a versionTag that is different from the last
 *   initialization of the view, then the view will automatically flush its tables, and re-populate itself.
 *
 * @param options
 *
 *   The options allow you to specify things like creating an in-memory-only view (non persistent).
**/

- (id)initWithGroupingBlock:(YapDatabaseViewGroupingBlock)groupingBlock
          groupingBlockType:(YapDatabaseViewBlockType)groupingBlockType
               sortingBlock:(YapDatabaseViewSortingBlock)sortingBlock
           sortingBlockType:(YapDatabaseViewBlockType)sortingBlockType;

- (id)initWithGroupingBlock:(YapDatabaseViewGroupingBlock)groupingBlock
          groupingBlockType:(YapDatabaseViewBlockType)groupingBlockType
               sortingBlock:(YapDatabaseViewSortingBlock)sortingBlock
           sortingBlockType:(YapDatabaseViewBlockType)sortingBlockType
                 versionTag:(NSString *)versionTag;

- (id)initWithGroupingBlock:(YapDatabaseViewGroupingBlock)groupingBlock
          groupingBlockType:(YapDatabaseViewBlockType)groupingBlockType
               sortingBlock:(YapDatabaseViewSortingBlock)sortingBlock
           sortingBlockType:(YapDatabaseViewBlockType)sortingBlockType
                 versionTag:(NSString *)versionTag
                    options:(YapDatabaseViewOptions *)options;

@property (nonatomic, strong, readonly) YapDatabaseViewGroupingBlock groupingBlock;
@property (nonatomic, strong, readonly) YapDatabaseViewSortingBlock sortingBlock;

@property (nonatomic, assign, readonly) YapDatabaseViewBlockType groupingBlockType;
@property (nonatomic, assign, readonly) YapDatabaseViewBlockType sortingBlockType;

/**
 * The versionTag assists you in updating your blocks.
 *
 * If you need to change the groupingBlock or sortingBlock,
 * then simply pass a different versionTag during the init method, and the view will automatically update itself.
 * 
 * If you want to keep things simple, you can use something like @"1",
 * representing version 1 of my groupingBlock & sortingBlock.
 * 
 * For more advanced applications, you may also include within the versionTag string:
 * - localization information (if you're using localized sorting routines)
 * - configuration information (if your sorting routine is based on some in-app configuration)
 *
 * For example, if you're sorting strings using a localized string compare method, then embedding the localization
 * information into your versionTag means the view will automatically re-populate itself (re-sort)
 * if the user launches the app in a different language than last time.
 * 
 * NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
 * NSString *versionTag = [NSString stringWithFormat:@"1-%@", localeIdentifier];
 * 
 * The groupingBlock/sortingBlock/versionTag can me changed after the view has been created.
 * See YapDatabaseViewTransaction(ReadWrite).
 * 
 * Note:
 * - [YapDatabaseView versionTag]            = versionTag of most recent commit
 * - [YapDatabaseViewTransaction versionTag] = versionTag of this commit
**/
@property (nonatomic, copy, readonly) NSString *versionTag;

/**
 * The options allow you to specify things like creating an in-memory-only view (non persistent).
**/
@property (nonatomic, copy, readonly) YapDatabaseViewOptions *options;

@end
