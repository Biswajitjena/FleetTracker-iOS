//
//  DBmanager.h
//  logindb
//
//  Created by Dhara on 15/12/15.
//  Copyright © 2015 Net4Nuts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBmanager : NSObject
@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;

@property (nonatomic) long long lastInsertedRowID;
-(NSArray *)loadDataFromDB:(NSString *)query;

-(void)executeQuery:(NSString *)query;




-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;

@end
