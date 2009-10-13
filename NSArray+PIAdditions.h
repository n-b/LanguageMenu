//
//  NSArray+PIAdditions.h
//
//  Created by Nicolas on 16/04/09.
//

#import <Foundation/Foundation.h>


@interface NSArray (PIAdditions)

/*
 * return objectAtIndex:0 or nil if empty
 */ 
- (id) firstObject;

/*
 * Pick a random() object in the array and return it.
 */
- (id) randomObject;

/*
 * return the object at index%count
 */
- (id) objectAtModuloIndex:(NSUInteger)aIndex;

/*
 * KVC related addition : find and return the first object in the array whose value for key *key* is equal to *value*.
 * will return null if no such object is found.
 */
- (id) firstObjectWithValue:(id)value forKey:(NSString*)key;

/*
 * KVC related addition : find and return the objects in the array whose value for key *key* is equal to *value*.
 * will return an empty array if no such object is found.
 */
- (NSArray*) filteredArrayWithValue:(id)value forKey:(NSString*)key;

/*
 * KVC related addition : find and return the objects who return a non-nil value when the passed selector is sent to them.
 */
- (NSArray*) filteredArrayWithSelector:(SEL)aFilterSelector;

@end
