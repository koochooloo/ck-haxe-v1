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

# ============================
# Image processing
# ============================

def resizeToMax( img, outWidth, outHeight ):
	# Determine image scale ratio
	inWidth, inHeight = img.size
	sizeRatio = 1

	if inWidth > inHeight: 
		sizeRatio = float(outWidth) / float(inWidth)
		print "Width size adjustment ratio: " + str(sizeRatio)
	elif inHeight >= inWidth:
		sizeRatio = float(outHeight) / float(inHeight)
		print "Height size adjustment ratio: " + str(sizeRatio)
	
	print "Final resize: " +  str( int(inWidth * sizeRatio) ) + " " + str( int(inHeight * sizeRatio) )
	
	return img.resize( ( int(inWidth * sizeRatio), int(inHeight * sizeRatio) ) )	

# ----------------------------
# Grab images from local folder into memory
# Resize images to:
# 	COUNTRY MAX - 1024x512
#	RECIPE MAX - 512x512
# ----------------------------
recipeFiles = [f for f in listdir(LOCAL_RECIPE_SRC_PATH) if isfile(join(LOCAL_RECIPE_SRC_PATH, f))]

for inPath in recipeFiles:
	root = os.path.splitext( inPath )[0]
	ext = os.path.splitext( inPath )[1]

	inPath = LOCAL_RECIPE_SRC_PATH + inPath
	outPath = LOCAL_RECIPE_DEST_PATH + root  + "_small" + ext
		
	print "Processing RECIPE image: " + inPath
	print "\tOut path: " + outPath

	try:
		img = Image.open(inPath);
		outImg = resizeToMax( img, RECIPE_MAX_WIDTH, RECIPE_MAX_HEIGHT )
		print "Attempting to save processed image " + outPath
		outImg.save( outPath )
	except IOError:
		print "Cannot process image " + inPath
		
countryFiles = [f for f in listdir(LOCAL_COUNTRY_SRC_PATH) if isfile(join(LOCAL_COUNTRY_SRC_PATH, f))]

for inPath in countryFiles:
	root = os.path.splitext( inPath )[0]
	ext = os.path.splitext( inPath )[1]

	inPath = LOCAL_COUNTRY_SRC_PATH + inPath
	outPath = LOCAL_COUNTRY_DEST_PATH + root  + "_small" + ext
		
	print "Processing COUNTRY image: " + inPath
	print "\tOut path: " + outPath

	try:
		img = Image.open(inPath);
		outImg = resizeToMax( img, COUNTRY_MAX_WIDTH, COUNTRY_MAX_HEIGHT )
		print "Attempting to save processed image " + outPath
		outImg.save( outPath )
	except IOError:
		print "Cannot process image " + inPath
		
		
		
		