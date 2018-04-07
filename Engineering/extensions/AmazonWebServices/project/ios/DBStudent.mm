#import "DBStudent.h"

@implementation DBStudent

+ (NSString *)dynamoDBTableName
{
    return @"Students";
}

+ (NSString *)hashKeyAttribute
{
    return @"StudentId";
}

@end

