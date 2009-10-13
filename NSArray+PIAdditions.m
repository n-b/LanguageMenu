//
//  NSArray+PIAdditions.m
//
//  Created by Nicolas on 16/04/09.
//

#import "NSArray+PIAdditions.h"


@implementation NSArray (PIAdditions)

- (id) firstObject
{
	if ([self count])
		return [self objectAtIndex:0];
	else
		return nil;
}

- (id) randomObject
{
	static BOOL init = FALSE;
	if(!init)
		srandomdev();
	return [self objectAtModuloIndex:random()];
}

- (id) objectAtModuloIndex:(NSUInteger)aIndex
{
	return [self objectAtIndex:aIndex%[self count]];
}

/****************************************************************************/
#pragma mark KVC-related Additions
// Using enumerators is probably faster than using NSPredicates.
// Moreover, predicates are 10.4+ only.
//
// In a 10.5 / Objective-C 2.0 World, we'd use fast enums.

- (id) firstObjectWithValue:(id)value forKey:(NSString*)key
{
	NSEnumerator* objectEnum = [self objectEnumerator];
	id object;
	
	while( (object = [objectEnum nextObject]) !=nil )
		if( [[object valueForKey:key] isEqual:value] )
			return object;
	return nil;
}

- (NSArray*) filteredArrayWithValue:(id)value forKey:(NSString*)key
{
	NSMutableArray * objects = [NSMutableArray arrayWithCapacity:[self count]];
	NSEnumerator* objectEnum = [self objectEnumerator];
	id object;
	
	while( (object = [objectEnum nextObject]) !=nil )
		if( [[object valueForKey:key] isEqual:value] )
			[objects addObject:object];
	
	return [NSArray arrayWithArray:objects];
}

- (NSArray*) filteredArrayWithSelector:(SEL)aFilterSelector
{
	NSMutableArray * objects = [NSMutableArray arrayWithCapacity:[self count]];
	NSEnumerator* objectEnum = [self objectEnumerator];
	id object;
	
	while( (object = [objectEnum nextObject]) !=nil )
		if( [object performSelector:aFilterSelector] )
			[objects addObject:object];
	
	return [NSArray arrayWithArray:objects];
}

@end
