#import "YapDatabaseQuery.h"
#import "YapDatabaseLogging.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * Define log level for this file: OFF, ERROR, WARN, INFO, VERBOSE
 * See YapDatabaseLogging.h for more information.
**/
#if DEBUG
  static const int ydbLogLevel = YDB_LOG_LEVEL_WARN;
#else
  static const int ydbLogLevel = YDB_LOG_LEVEL_WARN;
#endif


@implementation YapDatabaseQuery
{
	NSString *queryString;
	NSArray *queryParameters;
}

/**
 * A YapDatabaseQuery is everything after the SELECT clause of a query.
 * Methods that take YapDatabaseQuery parameters will prefix your query string similarly to:
 *
 * fullQuery = @"SELECT rowid FROM 'database' " + [yapDatabaseQuery queryString];
 *
 * Example 1:
 *
 * query = [YapDatabaseQuery queryWithFormat:@"WHERE jid = ?", message.jid];
 * [secondaryIndex enumerateKeysAndObjectsMatchingQuery:query
 *                                           usingBlock:^(NSString *key, id object, BOOL *stop){
 *     ...
 * }];
 *
 * Please note that you can ONLY pass objective-c objects as parameters.
 * Primitive types such as int, float, double, etc are NOT supported.
 * You MUST wrap these using NSNumber.
 *
 * Example 2:
 *
 * query = [YapDatabaseQuery queryWithFormat:@"WHERE department = ? AND salary >= ?", dept, @(minSalary)];
 * [secondaryIndex enumerateKeysAndObjectsMatchingQuery:query
 *                                           usingBlock:^(NSString *key, id object, BOOL *stop){
 *     ...
 * }];
**/
+ (instancetype)queryWithFormat:(NSString *)format, ...
{
	if (format == nil) return nil;
	
	NSUInteger paramCount = 0;
	NSUInteger formatLength = [format length];
	
	NSRange searchRange = NSMakeRange(0, formatLength);
	NSRange paramRange = [format rangeOfString:@"?" options:0 range:searchRange];
	
	while (paramRange.location != NSNotFound)
	{
		paramCount++;
		
		searchRange.location = paramRange.location + 1;
		searchRange.length = formatLength - searchRange.location;
		
		paramRange = [format rangeOfString:@"?" options:0 range:searchRange];
	}
	
	// Please note that you can ONLY pass objective-c objects as parameters.
	// Primitive types such as int, float, double, etc are NOT supported.
	// You MUST wrap these using NSNumber.
	
	NSMutableArray *queryParameters = [NSMutableArray arrayWithCapacity:paramCount];
	
	va_list args;
	va_start(args, format);
	
	@try
	{
		for (NSUInteger i = 0; i < paramCount; i++)
		{
			id param = va_arg(args, id);
			
			[queryParameters addObject:param];
		}
	}
	@catch (NSException *exception)
	{
		YDBLogError(@"Error processing query. Expected %lu parameters. All parameters must be objects. %@",
		            (unsigned long)paramCount, exception);
		
		queryParameters = nil;
	}
	
	va_end(args);
	
	if (queryParameters || (paramCount == 0))
	{
		return [[YapDatabaseQuery alloc] initWithQueryString:format queryParameters:queryParameters];
	}
	else
	{
		return nil;
	}
}


/**
 * Shorthand for a query with no 'WHERE' clause.
 * Equivalent to [YapDatabaseQuery queryWithFormat:@""].
**/
+ (instancetype)queryMatchingAll
{
	return [[YapDatabaseQuery alloc] initWithQueryString:@"" queryParameters:nil];
}

- (id)initWithQueryString:(NSString *)inQueryString queryParameters:(NSArray *)inQueryParameters
{
	if ((self = [super init]))
	{
		queryString = [inQueryString copy];
		queryParameters = [inQueryParameters copy];
	}
	return self;
}

@synthesize queryString;
@synthesize queryParameters;

@end
