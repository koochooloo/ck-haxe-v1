#import <AWSDynamoDB/AWSDynamoDB.h>

@class DBTeacher;

@interface DBTeacher : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *TeacherId;
@property (nonatomic, strong) NSString *GradeLevel;
@property (nonatomic, strong) NSNumber *Students;

@end
