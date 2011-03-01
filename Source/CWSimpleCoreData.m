//
//  CWSimpleCoreData.m
//
//  Created by Colin Wheeler on 9/20/09.
//  Copyright 2009 Colin Wheeler. All rights reserved.
//

/* based off of Martins M3SimpleCoreData but uses 
 * CWCoreDataCenter's singleton instance pointer to the managed object context or
 * the built in ManagedObjectContext [[NSApp delegate] managedObjectContext]
 */

#import "CWSimpleCoreData.h"
#import "CWCoreDataCenter.h"

@implementation CWSimpleCoreData

+(NSArray *)allEntitiesForName:(NSString *)entityName 
		inManagedObjectContext:(NSManagedObjectContext *)moc 
				 withPredicate:(NSPredicate *)predicate
			andSortDescriptors:(NSArray *)descriptors
					  andError:(NSError **)error
{
	if (!entityName) {
		return nil;
	}
	
	NSManagedObjectContext *context = nil;
	context = (moc != nil) ? moc : [[CWCoreDataCenter defaultCenter] managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName 
														 inManagedObjectContext:context];
	if (nil == entityDescription) {
		return nil;
	}
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:entityDescription];
	if (nil != predicate) {
		[request setPredicate:predicate];
	}
	if (nil != descriptors) {
		[request setSortDescriptors:descriptors];
	}
	
	NSArray *results = nil;
	
	results = [context executeFetchRequest:request 
									 error:error];
	
	/* assumes garbage collection */
	
	return results;
}

+(NSUInteger)objectCountForEntity:(NSString *)entityName 
		   inManagedObjectContext:(NSManagedObjectContext *)moc
						withError:(NSError **)error
{
	if (nil == entityName) {
		return 0;
	}
	
	NSManagedObjectContext *context = nil;
	context = (moc != nil) ? moc : [[CWCoreDataCenter defaultCenter] managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName 
														 inManagedObjectContext:context];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:entityDescription];
	[request setPredicate:nil];
	
	NSUInteger count;
	
	count = [moc countForFetchRequest:request error:error];
	
	return count;
}

+(NSManagedObject *)newObjectWithEntityName:(NSString *)entityName 
					 inManagedObjectContext:(NSManagedObjectContext *)moc 
								  andValues:(NSDictionary *)values
{
	if (!entityName || entityName == nil) {
		return nil;
	}
	
	/* if managedObjectConext is nil the assumption is you want
	 * the default application context that is [[NSApp delegate] managedObjectContext]
	 */
	NSManagedObjectContext *context = (nil != moc) ? moc : [[CWCoreDataCenter defaultCenter] managedObjectContext];
	
	NSEntityDescription * entityDesc = [NSEntityDescription entityForName:entityName 
												   inManagedObjectContext:context];
	if (nil == entityDesc) {
		return nil;
	}
	
	__block NSManagedObject *newMO = [[NSManagedObject alloc] initWithEntity:entityDesc 
										      insertIntoManagedObjectContext:context];
	if (!newMO) {
		return nil;
	}
	
	[values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[newMO setValue:obj forKey:key];
	}];
	
	return newMO;
}

/**
 Returns an array of NSDictionary objects containing just the specified
 properties that you wish to fetch.
 
 @param entityName A NSString containing the name of the entity to fetch
 @param moc The ManagedObjectContext to execute the fetch on
 @param predicate (Optional) a NSPredicate to filter the results
 @param properties the properties you wish to fetch from the entities
 @param descriptors (Optional) the sort descriptors you wish to apply to the results
 @param error a NSError object to write to if something goes wrong
 @return An array of NSDictionary objects with the properties that were specified to be fetched
 */
-(NSArray *)fetchEntitiesWithName:(NSString *)entityName 
		   inManagedObjectContext:(NSManagedObjectContext *)moc 
					withPredicate:(NSPredicate *)predicate
					   properties:(NSArray *)properties 
			   andSortDescriptors:(NSArray *)descriptors 
							error:(NSError **)error
{
	if (!entityName) {
		return nil;
	}
	
	NSManagedObjectContext *context = nil;
	context = (moc != nil) ? moc : [[CWCoreDataCenter defaultCenter] managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName 
														 inManagedObjectContext:context];
	if (nil == entityDescription) {
		return nil;
	}
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:entityDescription];
	if (nil != predicate) {
		[request setPredicate:predicate];
	}
	if (nil != descriptors) {
		[request setSortDescriptors:descriptors];
	}
	if (nil != properties) {
		[request setPropertiesToFetch:properties];
	}
	
	[request setResultType:NSDictionaryResultType];
	
	NSArray *results = nil;
	
	results = [context executeFetchRequest:request 
									 error:error];
	
	/* assumes garbage collection */
	
	return results;
}

@end
