#import "DBTeacher.h"

@implementation DBTeacher

+ (NSString *)dynamoDBTableName
{
    return @"Teachers";
}

+ (NSString *)hashKeyAttribute
{
    return @"TeacherId";
}

@end
