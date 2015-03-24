#import "NSManagedObject+ANDYObjectIDs.h"

@implementation NSManagedObject (ANDYObjectIDs)

+ (NSDictionary *)andy_dictionaryOfIDsAndFetchedIDsInContext:(NSManagedObjectContext *)context
                                               usingLocalKey:(NSString *)localKey
                                               forEntityName:(NSString *)entityName
{
    return [self andy_dictionaryOfIDsAndFetchedIDsUsingPredicate:nil
                                                     andLocalKey:localKey
                                                       inContext:context
                                                   forEntityName:entityName];
}

+ (NSDictionary *)andy_dictionaryOfIDsAndFetchedIDsUsingPredicate:(NSPredicate *)predicate
                                                      andLocalKey:(NSString *)localKey
                                                        inContext:(NSManagedObjectContext *)context
                                                    forEntityName:(NSString *)entityName
{
    __block NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [context performBlockAndWait:^{
        NSExpressionDescription *expression = [[NSExpressionDescription alloc] init];
        expression.name = @"objectID";
        expression.expression = [NSExpression expressionForEvaluatedObject];
        expression.expressionResultType = NSObjectIDAttributeType;

        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        request.predicate = predicate;
        request.resultType = NSDictionaryResultType;
        request.propertiesToFetch = @[expression, localKey];

        NSError *error = nil;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        if (error) NSLog(@"error fetching IDs: %@", [error description]);

        for (NSDictionary *object in objects) {

            id fetchedID = [object valueForKeyPath:localKey];

            NSManagedObjectID *objectID = [object valueForKeyPath:@"objectID"];

            if ([dictionary objectForKey:fetchedID] || !fetchedID) {
                [context deleteObject:[context objectWithID:objectID]];
            } else {
                [dictionary setObject:objectID forKey:fetchedID];
            }
        }
    }];

    return dictionary;
}

+ (NSArray *)andy_objectIDsInContext:(NSManagedObjectContext *)context
                 forEntityName:(NSString *)entityName
{
    return [self andy_objectIDsUsingPredicate:nil inContext:context forEntityName:entityName];
}

+ (NSArray *)andy_objectIDsUsingPredicate:(NSPredicate *)predicate
                                  inContext:(NSManagedObjectContext *)context
                              forEntityName:(NSString *)entityName
{
    __block NSArray *ids;

    [context performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        request.resultType = NSManagedObjectIDResultType;

        NSError *error = nil;
        ids = [context executeFetchRequest:request error:&error];
        if (error) NSLog(@"error fetching IDs: %@", [error description]);
    }];

    return ids;
}




@end
