//
//  SwpStitchingSQL.m
//  swp_song
//
//  Created by swp_song on 2017/2/11.
//  Copyright © 2017年 swp_song. All rights reserved.
//

#import "SwpStitchingSQL.h"

/*! ---------------------- Tool       ---------------------- !*/
#import "SwpFMDBTools.h"               // Tools
/*! ---------------------- Tool       ---------------------- !*/

@implementation SwpStitchingSQL

/**!
 *  @ author swp_song
 *
 *  @ brief  swpStitchingVerifyThatTheTableExistsSQL:   ( 验证 表 是否存 SQL )
 *
 *  @ param  modelClass
 *
 *  @ return NSString
 */
+ (NSString *)swpStitchingVerifyThatTheTableExistsSQL:(Class)modelClass {
    return [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master where type ='table' and name = '%@'", NSStringFromClass(modelClass)];
}

#pragma mark - Swp Stitching  Create Table SQL Methods
/**!
 *  @ author swp_song
 *
 *  @ brief  swpStitchingCreateTableSQL ( 拼接 创表 语句 )
 *
 *  @ param  modelClass
 *
 *  @ return NSString
 */
+ (NSString *)swpStitchingCreateTableSQL:(Class)modelClass {
    
    NSMutableString *createTableSQL = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT ,", NSStringFromClass(modelClass)];
    
    NSArray<NSString *> *properties = [SwpFMDBTools swpFMDBToolsGetAllPropertysNames:modelClass];
    
    [properties enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [createTableSQL appendFormat:@"%@,", key];
    }];
    
    [createTableSQL deleteCharactersInRange:NSMakeRange(createTableSQL.length - 1, 1)];
    [createTableSQL appendString:@")"];
    
    return createTableSQL.copy;
}

#pragma mark - Swp Stitching Inster SQL Methods
/**!
 *  @ author swp_song
 *
 *  @ brief  swpStitchingInsertSQL: ( 拼接 插入数据 SQL )
 *
 *  @ param  model
 *
 *  @ return NSString
 */
+ (NSString *)swpStitchingInsertSQL:(id)model {
    
    NSArray<NSString *> *propertys = [SwpFMDBTools swpFMDBToolsGetAllPropertysNames:[model class]];
    NSMutableString *insterSQL     = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ (", [model class]];
    NSMutableString *insterValue   = [NSMutableString string];
    
    [propertys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        
        id value = [model valueForKey:key];
        
        if (value == nil) value = @"";
        
        if ([SwpFMDBTools swpFMDBToolsVerifySystemCollectionType:value]) {
            value = [SwpFMDBTools swpFMDBToolsSetConversionJSONSting:value];
        }
        
        value = value ? [NSString stringWithFormat:@"'%@'", value] : value;
        
        // 拼接 插入 数据 value
        [insterValue appendString:idx == propertys.count - 1 ? [NSString stringWithFormat:@"%@", value] : [NSString stringWithFormat:@"%@,", value]];
        [insterSQL appendFormat:@"%@,", key];
    }];
    
    [insterSQL deleteCharactersInRange:NSMakeRange(insterSQL.length - 1, 1)];
    [insterSQL appendFormat:@") VALUES (%@);", insterValue];
    
    return insterSQL;
}

#pragma mark - Swp Stitching Update SQL Methods
/**!
 *  @ author swp_song
 *
 *  @ brief  swpStitchingUpdateSQLConditionSwpDBID: ( 拼接 修改数据 SQL )
 *
 *  @ param  model
 *
 *  @ return NSString
 */
+ (NSString *)swpStitchingUpdateSQLConditionSwpDBID:(id)model {
    return [[self class] swpStitchingUpdateSQL:model conditionKey:@"swpDBID" conditionValue:[model valueForKey:@"swpDBID"]];
}

/**!
 *  @ author swp_song
 *
 *  @ brief  swpStitchingUpdateSQL:conditionKey:conditionValue: ( 拼接 修改数据 SQL )
 *
 *  @ param  model
 *
 *  @ param  key
 *
 *  @ param  value
 *
 *  @ return NSString
 */
+ (NSString *)swpStitchingUpdateSQL:(id)model conditionKey:(NSString *)key conditionValue:(NSString *)value {
    
    NSArray<NSString *> *propertys = [SwpFMDBTools swpFMDBToolsGetAllPropertysNames:[model class]];
    NSMutableString     *updateSQL = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", [model class]];
    [propertys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = [model valueForKey:key];
        
        if (value == nil) value = @"";
        
        if ([SwpFMDBTools swpFMDBToolsVerifySystemCollectionType:value]) {
            value = [SwpFMDBTools swpFMDBToolsSetConversionJSONSting:value];
        }
        
        value = value ? [NSString stringWithFormat:@"'%@'", value] : value;
        
        [updateSQL appendString:idx == propertys.count - 1 ? [NSString stringWithFormat:@"%@ = %@", key, value] : [NSString stringWithFormat:@"%@ = %@, ", key, value]];
    }];
    [updateSQL appendFormat:@" WHERE %@ = '%@';", key, value];
    return updateSQL.copy;
}

#pragma mark - Swp Stitching Select SQL Methods

/**!
 *  @ author swp_song
 *
 *  @ brief  swpStitchingSelectDataSQL:key:value:   ( 根据 主键 查询 数据 )
 *
 *  @ param  modelClass
 *
 *  @ param  key
 *
 *  @ param  value
 *
 *  @ return NSString
 */
+ (NSString *)swpStitchingSelectDataSQL:(Class)modelClass key:(NSString *)key value:(NSString *)value {
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@';", NSStringFromClass(modelClass), key, value];
}

/**!
 *  @ author swp_song
 *
 *  @ brief  swpStitchingSelectModelSQL:swpBDID:    ( 查询 根据 swpBDID 数据 SQL < 单条数据 > )
 *
 *  @ param  modelClass
 *
 *  @ param  swpBDID
 *
 *  @ return NSString
 */
+ (NSString *)swpStitchingSelectModelSQL:(Class)modelClass swpDBID:(NSString *)swpDBID {
    return [[self class] swpStitchingSelectDataSQL:modelClass key:@"swpDBID" value:swpDBID];
}


/**!
 *  @ author swp_song
 *
 *  @ brief  swpStitchingSelectDataSQL:key:value:   ( 查询 全部 数据 SQL < 单条数据 > )
 *
 *  @ param  modelClass
 *
 *  @ return NSString
 */
+ (NSString *)swpStitchingSelectModelsSQL:(Class)modelClass {
    return [NSString stringWithFormat:@"SELECT * FROM %@;", NSStringFromClass(modelClass)];
}

#pragma mark - Swp Stitching Delete SQL Methods
/**!
 *  @ author swp_song
 *
 *  @ brief  swpStitchingDeleteModelSQL:key:value: ( 删除 单条 数据 SQL < 单条数据 > )
 *
 *  @ param  modelClass
 *
 *  @ param  key
 *
 *  @ param  value
 *
 *  @ return NSString
 */
+ (NSString *)swpStitchingDeleteModelSQL:(Class)modelClass key:(NSString *)key value:(NSString *)value {
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@';", NSStringFromClass(modelClass), key, value];
}

/**!
 *  @ author swp_song
 *
 *  @ brief  swpStitchingDeleteModelSQL:swpDBID:   ( 删除 单条 数据 SQL 根据 swpDBID < 单条数据 > )
 *
 *  @ param  modelClass
 *
 *  @ param  swpDBID
 *
 *  @ return NSString
 */
+ (NSString *)swpStitchingDeleteModelSQL:(Class)modelClass swpDBID:(NSString *)swpDBID {
    return [[self class] swpStitchingDeleteModelSQL:modelClass key:@"swpDBID" value:swpDBID];
}

/**!
 *  @ author swp_song
 *
 *  @ brief  swpStitchingDeleteModelsSQL:models:    ( 删除 一组 数据 SQL 根据 swpDBID < 删除一组数据 > )
 *
 *  @ param  modelClass
 *
 *  @ param  models
 *
 *  @ return NSString
 */
+ (NSString *)swpStitchingDeleteModelsSQL:(Class)modelClass models:(NSArray *)models {
    
    NSMutableString *deleteSQL = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE swpDBID IN ( ", [modelClass class]];
    [models enumerateObjectsUsingBlock:^(id _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@", [model valueForKey:@"swpDBID"]);
        [deleteSQL appendFormat:@"'%@', ", [model valueForKey:@"swpDBID"]];
    }];
    
    [deleteSQL deleteCharactersInRange:NSMakeRange(deleteSQL.length - 2, 1)];
    [deleteSQL appendString:@");"];
    return [NSString stringWithFormat:@"%@", deleteSQL];
}

/**!
 *  @ author swp_song
 *
 *  @ brief  swpStitchingClearModelsSQL:    ( 清空表数据 )
 *
 *  @ param  modelClass
 *
 *  @ return NSString
 */
+ (NSString *)swpStitchingClearModelsSQL:(Class)modelClass {
    return [NSString stringWithFormat:@"DELETE FROM %@", NSStringFromClass(modelClass)];
}


@end
