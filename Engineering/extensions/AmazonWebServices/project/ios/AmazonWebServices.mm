#include "Utils.h"

#import "DBTeacher.h"
#import "DBStudent.h"

#import <UIKit/UIKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import <AWSDynamoDB/AWSDynamoDB.h>


void onLoadTeacher(DBTeacher *teacher);
void onLoadStudent(DBStudent *student);
void onLoadError(const char *msg);

namespace amazonwebservices {
	
	
	int SampleMethod(int inputValue) {
		
		return inputValue * 200;
		
	}

	void connect()
    {
        //TODO:  Would be nice to pass in region and poolId.  Region enum makes it a little annoying.
        NSString *awsIdentityPoolId = @"us-west-2:da5309fa-e5f6-424c-897c-7570e208c117";

        AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] 
                        initWithRegionType:AWSRegionUSWest2 identityPoolId:awsIdentityPoolId];

        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] 
                        initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];

        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    }

    void loadTeacher(const char * teacherId)
    {
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];

        NSString *nsId = [NSString stringWithUTF8String:teacherId];
        [[dynamoDBObjectMapper load:[DBTeacher class] hashKey:nsId rangeKey:nil] continueWithBlock: 
                ^id(AWSTask *task)
                {
                    dispatch_async(dispatch_get_main_queue(),
                        ^{
                            if (task.error)
                            {
                                NSLog(@"Error: [%@]", task.error);
                                const char *msg = [[NSString stringWithFormat:@"%@", task.error] UTF8String];
                                onLoadError(msg);
                            }
                            else
                            {
                                DBTeacher *teach = task.result;
                                onLoadTeacher(teach);
                            }
                        });

                    return nil;
                }];
    }

    void loadStudent(const char * studentId)
    {
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];

        NSString *nsId = [NSString stringWithUTF8String:studentId];
        [[dynamoDBObjectMapper load:[DBStudent class] hashKey:nsId rangeKey:nil] continueWithBlock: 
                ^id(AWSTask *task)
                {
                    dispatch_async(dispatch_get_main_queue(),
                        ^{
                            if (task.error)
                            {
                                NSLog(@"Error: [%@]", task.error);
                                const char *msg = [[NSString stringWithFormat:@"%@", task.error] UTF8String];
                                onLoadError(msg);
                            }
                            else
                            {
                                DBStudent *student = task.result;
                                onLoadStudent(student);
                            }

                        });
                    return nil;
                }];
    }

    void saveStudent(const char *studentId, const char *teacherId, const char *saveData, const char *profileData)
    {
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];

        DBStudent *student = [DBStudent new];
        student.StudentId = [NSString stringWithUTF8String: studentId];
        student.TeacherId = [NSString stringWithUTF8String: teacherId];
        student.SaveData = [NSString stringWithUTF8String: saveData];
        student.Profile = [NSString stringWithUTF8String: profileData];

        [[dynamoDBObjectMapper save: student] continueWithBlock:
            ^id(AWSTask *task)
            {
                if (task.error)
                {
                    NSLog(@"**** Error saving student ****");
                }
                else
                {
                    //NSLog(@"Student Saved!!!!!");
                }

                return nil;
            }];
    }
	
}
