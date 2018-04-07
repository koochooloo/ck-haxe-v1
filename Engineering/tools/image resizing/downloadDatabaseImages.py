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
# Download images from Chef K portal to a local folder
# Reference: https://aws.amazon.com/developers/getting-started/python/
#			 https://github.com/aws-samples/aws-python-sample/blob/master/s3_sample.py
#			 https://boto3.readthedocs.io/en/latest/guide/s3-example-download-file.html
# Requires installation of boto3: http://boto.cloudhackers.com/en/latest/
# Need to configure file: C:\Users\USER_NAME\.aws\credentials with AWS user credentials
#		See: https://drive.google.com/a/1stplayable.com/file/d/0B093kQ_WdPZ8Sk5Sc3Y5emNmc2c/view?usp=sharing
# ----------------------------

# Instantiate a new client object - will reference credentials file
s3client = boto3.client('s3')
s3 = boto3.resource('s3')

'''
# Debugging
print "List s3 buckets:"
list_buckets_resp = s3client.list_buckets()
for bucket in list_buckets_resp['Buckets']:
    print bucket
'''

# Get database data bucket
bucket = s3.Bucket( DB_BUCKET_NAME )

'''
# Debugging
print "List s3 bucket contents: "
for file in bucket.objects.all():
    print file.key
'''

# Download bucket recipe content
for file in bucket.objects.all():
	if DB_RECIPE_IMG_PATH in file.key:
		if "." in file.key:
			print "Downloading recipe " + file.key
			roots = file.key.split("/")
			root = roots[ len(roots) - 1 ]
			local_path = LOCAL_RECIPE_SRC_PATH + root
			print "\t to local path " + local_path
			
			try:
				bucket.download_file( file.key, local_path )
			except botocore.exceptions.ClientError as e:
				if e.response['Error']['Code'] == "404":
					print "Object " + file.key + " does not exist."
				else:
					raise
	elif DB_COUNTRY_IMG_PATH in file.key:
		if "." in file.key:
			print "Downloading country " + file.key
			roots = file.key.split("/")
			root = roots[ len(roots) - 1 ]
			local_path = LOCAL_COUNTRY_SRC_PATH + root
			print "\t to local path " + local_path
			
			try:
				bucket.download_file( file.key, local_path )
			except botocore.exceptions.ClientError as e:
				if e.response['Error']['Code'] == "404":
					print "Object " + file.key + " does not exist."
				else:
					raise