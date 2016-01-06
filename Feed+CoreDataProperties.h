//
//  Feed+CoreDataProperties.h
//  RSSFeedReader
//
//  Created by Administrateur on 06/01/2016.
//  Copyright © 2016 com.epsi.projeti5.rssfeedreader. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Feed.h"

NS_ASSUME_NONNULL_BEGIN

@interface Feed (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSString *name;

@end

NS_ASSUME_NONNULL_END
