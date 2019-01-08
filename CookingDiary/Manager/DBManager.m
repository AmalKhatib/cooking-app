//
//  DBManager.m
//  CookingDiary
//
//  Created by Roger Molas on 05/01/2019.
//  Copyright © 2019 Roger Molas. All rights reserved.
//

#import "DBManager.h"
#import "RecipeModel.h"

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBManager

+ (DBManager *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DBManager alloc] init];
    });
    return sharedInstance;
}

- (BOOL)insertData:(NSString *)query
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into recipe (name, people, grams, image) values(\"%s\",\"%d\", \"%s\", \"%s\")", "ddd", 1, "ddd", "dddd"];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

- (NSArray *)findBy:(NSString *)query
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        const char *query_stmt = [query UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                RecipeModel *model = [[RecipeModel alloc] init];
                NSString *name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                NSInteger people = sqlite3_column_int(statement, 1);
                NSString *grams = [[NSString alloc]initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                NSString *image = [[NSString alloc]initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                model.name = name;
                model.people = people;
                model.grams = grams;
                model.image = image;
                [resultArray addObject:model];
            }
            sqlite3_reset(statement);
            return resultArray;
            
        } else {
            NSLog(@"Not found");
            return nil;
        }
    }
    return nil;
}
@end
