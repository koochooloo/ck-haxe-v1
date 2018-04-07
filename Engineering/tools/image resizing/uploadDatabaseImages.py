from PIL import Image
import sys
import os.path
from os import listdir
from os.path import isfile, join
import boto3
import botocore
import uuid

# ============================
# Tunables
# ============================

COUNTRY_MAX_WIDTH = 1024
COUNTRY_MAX_HEIGHT = 512
RECIPE_MAX_WIDTH = 512
RECIPE_MAX_HEIGHT = 512

LOCAL_RECIPE_SRC_PATH = "db_imgs/recipe/"
LOCAL_RECIPE_DEST_PATH = "db_imgs_resized/recipe/"

LOCAL_COUNTRY_SRC_PATH = "db_imgs/country/"
LOCAL_COUNTRY_DEST_PATH = "db_imgs_resized/country/"

DB_BUCKET_NAME = "chefk-prod"
DB_RECIPE_IMG_PATH = "uploads/recipe_image/image/"
DB_COUNTRY_IMG_PATH = "uploads/country/image"

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
bucket = s3.Bucket( DB_BUCKET_NAME )

# Upload resized images to s3 bucket
recipeFiles = [f for f in listdir(LOCAL_RECIPE_DEST_PATH) if isfile(join(LOCAL_RECIPE_DEST_PATH, f))]
for file in recipeFiles:
	print "Uploading " + file
	localFilePath = LOCAL_RECIPE_DEST_PATH + file
	print "\tFrom local path: " + localFilePath
	dbFilePath = DB_RECIPE_IMG_PATH + file
	print "\tTo bucket path: " + dbFilePath
	s3.meta.client.upload_file( localFilePath, DB_BUCKET_NAME, dbFilePath )
	
countryFiles = [f for f in listdir(LOCAL_COUNTRY_DEST_PATH) if isfile(join(LOCAL_COUNTRY_DEST_PATH, f))]
for file in countryFiles:
	print "Uploading " + file
	localFilePath = LOCAL_COUNTRY_DEST_PATH + file
	print "\tFrom local path: " + localFilePath
	dbFilePath = DB_COUNTRY_IMG_PATH + file
	print "\tTo bucket path: " + dbFilePath
	s3.meta.client.upload_file( localFilePath, DB_BUCKET_NAME, dbFilePath )


