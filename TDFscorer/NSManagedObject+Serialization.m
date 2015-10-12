//
//  NSManagedObject+Serialization.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/05.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "NSManagedObject+Serialization.h"

@implementation NSManagedObject (Serialization)

#define DATE_ATTR_PREFIX @"dAtEaTtr:"
#warning "Change CLASS_PREFIX if it's not ABC"
#define CLASS_PREFIX @"ABC"

#pragma mark -
#pragma mark Dictionary conversion methods

- (NSDictionary*) toDictionaryWithTraversalHistory:(NSMutableSet*)traversalHistory ignorePhoto:(BOOL)ignoreDataPhoto{
    NSArray* attributes = [[[self entity] attributesByName] allKeys];
    NSArray* relationships = [[[self entity] relationshipsByName] allKeys];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:
                                 [attributes count] + [relationships count] + 1];
    
    NSMutableSet *localTraversalHistory = nil;
    
    if (traversalHistory == nil) {
        localTraversalHistory = [NSMutableSet setWithCapacity:[attributes count] + [relationships count] + 1];
    } else {
        localTraversalHistory = traversalHistory;
    }
    
    [localTraversalHistory addObject:self];
    
    [dict setObject:[[self class] description] forKey:@"class"];
    
    for (NSString* attr in attributes) {
        NSObject* value = [self valueForKey:attr];
        
        if (value != nil) {
            if ([value isKindOfClass:[NSDate class]]) {
                NSTimeInterval date = [(NSDate*)value timeIntervalSinceReferenceDate];
                NSString *dateAttr = [NSString stringWithFormat:@"%@%@", DATE_ATTR_PREFIX, attr];
                [dict setObject:[NSNumber numberWithDouble:date] forKey:dateAttr];
            } else {
                if ([value isKindOfClass:[NSData class]] && ignoreDataPhoto){
// Type photo so ignore if flag is set
                }else{
                    [dict setObject:value forKey:attr];
                }
            }
        }
    }
    
    for (NSString* relationship in relationships) {
        NSObject* value = [self valueForKey:relationship];
        
        if ([value isKindOfClass:[NSSet class]]) {
            // To-many relationship
            
            // The core data set holds a collection of managed objects
            NSSet* relatedObjects = (NSSet*) value;
            
            // Our set holds a collection of dictionaries
            NSMutableArray* dictSet = [NSMutableArray arrayWithCapacity:[relatedObjects count]];
            
            for (NSManagedObject* relatedObject in relatedObjects) {
                if ([localTraversalHistory containsObject:relatedObject] == NO) {
                    [dictSet addObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory ignorePhoto:ignoreDataPhoto]];
                }
            }
            
            [dict setObject:[NSArray arrayWithArray:dictSet] forKey:relationship];
        }
        else if ([value isKindOfClass:[NSOrderedSet class]]) {
            // To-many relationship
            
            // The core data set holds an ordered collection of managed objects
            NSOrderedSet* relatedObjects = (NSOrderedSet*) value;
            
            // Our ordered set holds a collection of dictionaries
            NSMutableArray* dictSet = [NSMutableArray arrayWithCapacity:[relatedObjects count]];
            
            for (NSManagedObject* relatedObject in relatedObjects) {
                if ([localTraversalHistory containsObject:relatedObject] == NO) {
                    [dictSet addObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory ignorePhoto:ignoreDataPhoto]];
                }
            }
            
            [dict setObject:[NSOrderedSet orderedSetWithArray:dictSet] forKey:relationship];
        }
        else if ([value isKindOfClass:[NSManagedObject class]]) {
            // To-one relationship
            
            NSManagedObject* relatedObject = (NSManagedObject*) value;
            
            if ([localTraversalHistory containsObject:relatedObject] == NO) {
                // Call toDictionary on the referenced object and put the result back into our dictionary.
                [dict setObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory ignorePhoto:ignoreDataPhoto] forKey:relationship];
            }
        }
    }
    
    if (traversalHistory == nil) {
        [localTraversalHistory removeAllObjects];
    }
    
    return dict;
}

- (NSDictionary*) toDictionary:(BOOL)ignoreDataPhoto {
    // Check to see there are any objects that should be skipped in the traversal.
    // This method can be optionally implemented by NSManagedObject subclasses.
    NSMutableSet *traversedObjects = nil;
    if ([self respondsToSelector:@selector(serializationObjectsToSkip)]) {
        traversedObjects = [self performSelector:@selector(serializationObjectsToSkip)];
    }
    return [self toDictionaryWithTraversalHistory:traversedObjects ignorePhoto:ignoreDataPhoto];
}

+ (id) decodedValueFrom:(id)codedValue forKey:(NSString*)key {
    if ([key hasPrefix:DATE_ATTR_PREFIX] == YES) {
        // This is a date attribute
        NSTimeInterval dateAttr = [(NSNumber*)codedValue doubleValue];
        
        return [NSDate dateWithTimeIntervalSinceReferenceDate:dateAttr];
    } else {
        // This is an attribute
        return codedValue;
    }
}

- (void) populateFromDictionary:(NSDictionary*)dict context:(NSManagedObjectContext *)context{// intoEmptyCtx:(BOOL)intoEmptyCtx{
//    NSManagedObjectContext* context = [self managedObjectContext];
    
    for (NSString* key in dict) {
        if ([key isEqualToString:@"class"]) {
            continue;
        }
        
        NSObject* value = [dict objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            // This is a to-one relationship
            NSManagedObject* relatedObject = [NSManagedObject createManagedObjectFromDictionary:(NSDictionary*)value inContext:context];
            
            [self setValue:relatedObject forKey:key];
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            // This is a to-many relationship
            NSArray* relatedObjectDictionaries = (NSArray*) value;
            
            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableSet* relatedObjects = [self mutableSetValueForKey:key];
            
            for (NSDictionary* relatedObjectDict in relatedObjectDictionaries) {
                NSManagedObject* relatedObject = [NSManagedObject createManagedObjectFromDictionary:relatedObjectDict inContext:context];
                [relatedObjects addObject:relatedObject];
            }
        }
        else if ([value isKindOfClass:[NSOrderedSet class]]) {
            // This is a to-many relationship
            NSArray* relatedObjectDictionaries = (NSArray*) value;
            
            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableOrderedSet* relatedObjects = [self mutableOrderedSetValueForKey:key];
            
            for (NSDictionary* relatedObjectDict in relatedObjectDictionaries) {
                NSManagedObject* relatedObject = [NSManagedObject createManagedObjectFromDictionary:relatedObjectDict inContext:context];
                [relatedObjects addObject:relatedObject];
            }
        }
        else if (value != nil) {
            if ([key hasPrefix:DATE_ATTR_PREFIX] == NO)
                [self setValue:[NSManagedObject decodedValueFrom:value forKey:key] forKey:key];
            else {
                //  the entity Transaction is not key value coding-compliant for the key "dAtEaTtr:timestamp".
                NSString *originalKey = [key stringByReplacingOccurrencesOfString:DATE_ATTR_PREFIX withString:@""];
                [self setValue:[NSManagedObject decodedValueFrom:value forKey:key] forKey:originalKey];
            }
        }
    }
}

+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                             inContext:(NSManagedObjectContext*)context// intoEmptyCtx:(BOOL)intoEmptyCtx
{
    NSString* class = [dict objectForKey:@"class"];
    
    // strip off class prefix, if the names in our data model don't match the class names!
    NSString* name = [class stringByReplacingOccurrencesOfString:CLASS_PREFIX withString:@""];
    NSManagedObject *newObject;
//    if (intoEmptyCtx) {
//        NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:context];
//        newObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
//    }else{
        newObject = (NSManagedObject*)[NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
//    }
    
    [newObject populateFromDictionary:dict context:context];
    
    return newObject;
}

@end