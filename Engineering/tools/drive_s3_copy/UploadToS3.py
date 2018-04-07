from PIL import Image
import sys
import os.path
from os import listdir
from os.path import isfile, join
import boto3
import botocore
import uuid

LOCAL_IMAGES = "images/"
LOCAL_AUDIO = "audio/"

S3_BUCKET_NAME = "chefk-prod"
S3_IMAGES = "curriculum/images/"
S3_AUDIO = "curriculum/audio/"

# ----------------------------
# Upload images from local folder to Chef K S3 bucket.
# Reference: https://aws.amazon.com/developers/getting-started/python/
#			 https://github.com/aws-samples/aws-python-sample/blob/master/s3_sample.py
# Requires installation of boto3: http://boto.cloudhackers.com/en/latest/
# Need to configure file: C:\Users\USER_NAME\.aws\credentials with AWS user credentials
#		See: https://drive.google.com/a/1stplayable.com/file/d/0B093kQ_WdPZ8Sk5Sc3Y5emNmc2c/view?usp=sharing
# ----------------------------

# Instantiate a new client object - will reference credentials file
s3client = boto3.client('s3')
s3 = boto3.resource('s3')

# Get database data bucket
bucket = s3.Bucket( S3_BUCKET_NAME )

images = [f for f in listdir(LOCAL_IMAGES) if isfile(join(LOCAL_IMAGES, f))]
for file in images:
	print "Uploading " + file
	localFilePath = LOCAL_IMAGES + file
	print "\tFrom local path: " + localFilePath
	dbFilePath = S3_IMAGES + file
	print "\tTo bucket path: " + dbFilePath
	s3.meta.client.upload_file( localFilePath, S3_BUCKET_NAME, dbFilePath )

audios = [f for f in listdir(LOCAL_AUDIO) if isfile(join(LOCAL_AUDIO, f))]
for file in audios:
	print "Uploading " + file
	localFilePath = LOCAL_AUDIO + file
	print "\tFrom local path: " + localFilePath
	dbFilePath = S3_AUDIO + file
	print "\tTo bucket path: " + dbFilePath
	s3.meta.client.upload_file( localFilePath, S3_BUCKET_NAME, dbFilePath )
