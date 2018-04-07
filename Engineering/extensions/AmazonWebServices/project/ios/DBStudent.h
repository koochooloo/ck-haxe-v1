#import <AWSDynamoDB/AWSDynamoDB.h>

@class DBStudent;

@interface DBStudent : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *StudentId;
@property (nonatomic, strong) NSString *TeacherId;
@property (nonatomic, strong) NSString *SaveData;
@property (nonatomic, strong) NSString *Profile;

@end

