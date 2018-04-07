<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title>Chef Koochooloo + CMS Export</title>
		<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/normalize/4.1.1/normalize.min.css">
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
		<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Open+Sans:400,700,800italic,400italic,300">
		<link rel="stylesheet" href="admin.css">
	</head>
<?php
	ob_start();

	require 'vendor/autoload.php';

	// Setup AWS SDK for DynamoDB
	$sdk = new Aws\Sdk([
	    'region'   => 'us-west-2',
	    'version'  => 'latest'
	]);
	$dynamodb = $sdk->createDynamoDb();

	// Setup AWS SDK for S3
	use Aws\S3\S3Client;
	// TODO:  Credentials probably shouldn't live in the script...
	$s3client = S3Client::factory([
		'region'   => 'us-west-2',
		'version'  => 'latest',
		'credentials' => [
			'key'		=>	'AKIAJU2LNXLM2Q4GIXJQ',
			'secret'	=>	'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'
		]
	]);

	// Setup Google Sheets API
	define( 'SCOPES', implode( ' ', array(
		Google_Service_Sheets::SPREADSHEETS_READONLY
	)));
	$client = new Google_Client();
	$client->setApplicationName( "CMS Sheet Exporter" );
	$client->setAuthConfig( "service-account-credentials.json" );
	$client->setScopes( SCOPES );
	$service = new Google_Service_Sheets( $client );

	// Defines
	$CMS_ID = '10v8v_Jn_5kFeD0eGSB-yEgV3gYdt8cKvkiLsy2wbqgw';
	$S3_PATH = 'curriculum/cms/';
	$ERRHEAD = "";
	$ERRMSG = "";
	$output = "";

	// Define the sheet index within the Google Sheet, used when acquiring the JSON
	// Each array includes Sheet Tab ID, Sheet Tab Name, Sheet Range to load, an array of indexes 
	// into the range indicating the columns to be ignored
	//TODO: These ranges should probably be generated dynamically, extending out to the right to 
	//		fit the columns needed. It's possible the number of years may change with future CMS 
	//		updates.
	$CMS_SHEETS_LIST = [
		'SocialStudies'					=> [ 0,				"Social Studies", 	"!A:W",		[] ],
		'MathAndScience'				=> [ 417079567,		"MathAndScience", 	"!A:T",		[] ],
		'ZeroWeekAssessment'			=> [ 1630199788,	"0WeekAssessment", 	"!A:U",		[] ],
		'FiveWeekAssessment'			=> [ 246410350,		"5WeekAssessment", 	"!A:U",		[] ],
		'TenWeekAssessment'				=> [ 1881593932,	"10WeekAssessment",	"!A:U",		[] ]
	];

	/**
	 * Remove columns from a range of data by index into the row.
	 * @param  array   $row  A row of data gathered from the imported sheet range.
	 * @param  array   $cols An array of indexes into the data array.
	 * @return array         The source row returned as an array with indexed values removed.
	 */
	function removeCols( $row, $cols )
	{
		rsort( $cols );
		foreach ( $cols as $col )
		{
			unset( $row[ $col ] );
		}
		return $row;
	}

	/**
	 * Generate the Data for a section of CMS as JSON from rows within a Google Sheet.
	 * @param  string  $sheet      Sheet ID provided by Google Sheets.
	 * @param  string  $range      Range to pull from the Google Sheet, using A1 notation.
	 * @param  array   $skipcols   Array of column indexes into the imported range that should be 
	 *                             ignored.	
	 * @param  bool    $data_int   Specify whether the data should exist as an int or not. 
	 *                             Determines whether the generated JSON values are wrapped in 
	 *                             quotes.
	 * @return string              Data JSON content to be drawn.
	 */
	function drawData( $sheet, $range, $skipcols, $data_int = false )
	{
		global $service, $ERRHEAD, $ERRMSG;

		try {
			$results = $service->spreadsheets_values->get( $sheet, $range );
		} catch ( Exception $e)
		{
			$ERRHEAD = "An error has occurred.";
			$ERRMSG = $e->getMessage();
			return "";
		}

		$data_output = "[\n";
		$values = $results->getValues();

		// First row has the names of the items
		$headers = $values[0];
		// Remove unneeded columns from the sheet's range
		$headers = removeCols( $headers, $skipcols );

		// We can always ignore the first row of data returned
		$values = array_slice( $values, 1 );

		$i = 0;
		$len = count( $values );
		foreach ( $values as $row ) {

			// Drop out once we hit an empty key
			if ( $row[ 0 ] == "" )
			{
				break;
			}

			// Remove unneeded columns from the sheet's range
			$row = removeCols( $row, $skipcols );

			$data_output .= "\t{\n";

			// Write each item in the row as "key" : "value"
			$j_len = count($headers);
			for($j = 0; $j < $j_len; $j++)
			{
				$data_output .= "\t\t\"{$headers[$j]}\": ";

				// We want "", not null, for items that don't exist
				$val = is_null($row[$j]) ? "\"\"" : json_encode($row[$j]);
				$data_output .= $val;

				if ( $j < $j_len - 1)
				{
					$data_output .= ",\n";
				}
				else
				{
					$data_output .= "\n";
				}
			}

			// Don't add stray comma to last row of content followed by empty rows 
			if ( ( $i == $len - 1 ) || ( $values[ $i + 1 ][ 0 ] == "" ) )
			{
				$data_output .= "\t}\n";
			}
			else
			{
				$data_output .= "\t},\n";
			}

			$i++;
		}

		$data_output .= "]";

		return $data_output;
	}

	/**
	 * Utility function for drawing a header, data, and footer for each section.
	 * @param  string  $section  Section name.
	 * @param  boolean $data_int Draw data as int rather than string.
	 * @return string            Section output string.
	 */
	function drawSection( $section, $data_int = false, $islast = false )
	{
		global $CMS_ID, $CMS_SHEETS_LIST;
		$data_output = "";
		$data_output .= drawData( $CMS_ID, 
							 $CMS_SHEETS_LIST[ $section ][ 1 ] . $CMS_SHEETS_LIST[ $section ][ 2 ], 
							 $CMS_SHEETS_LIST[ $section ][ 3 ], 
							 $data_int );
		reportSuccess();
		return $data_output;
	}

	/**
	 * Utility function to export cms file to S3
	 * @param  string  $section  Section name, used for filename.
	 * @param  string  $contents JSON object to be written to the file.
	 */
	function exportFile( $section, $contents)
	{
		global $S3_PATH, $ERRHEAD, $ERRMSG;

		// Custom error handler for S3 PUT
		set_error_handler(
			create_function(
				'$severity, $message, $file, $line',
				'throw new ErrorException($message, $severity, $severity, $file, $line);'
			)
		);

		$filename = "{$section}.json";

		if ( strlen( $ERRHEAD ) == 0 )
		{
			echo "\t\t<p>Writing {$filename} to {$S3_PATH}...</p>\n";
			ob_flush();

			try {
				@file_put_contents( "s3://chefk-prod/{$S3_PATH}{$filename}", $contents );
			} catch ( Exception $e )
			{
				$ERRHEAD = "An error has occurred.";
				$ERRMSG = $e->getMessage();
			}
			reportSuccess();
		}

		restore_error_handler();
	}

	/**
	 * Utility function to report success on an action
	 * @param  string $str The string to echo.
	 */
	function reportSuccess( $str = "\t\t<p class=\"indent\">Done.</p>\n" )
	{
		global $ERRHEAD;
		if ( strlen( $ERRHEAD ) == 0 )
		{
			echo $str;
		}
	}
?>
	<body>
		<h1>CMS Data Export</h1>
<?php

	if ( strlen( $ERRHEAD ) == 0 )
	{
		echo "\t\t<p>Creating S3 stream...</p>\n";
		ob_flush();

		try {
			$s3client->registerStreamWrapper();
		} catch ( \Aws\S3\Exception\S3Exception $e )
		{
			$ERRHEAD = "An error has occurred.";
			$ERRMSG = $e->getAwsErrorCode() . "\n";
			$ERRMSG .= $e->getMessage();
		}
		reportSuccess();
	}

	if ( strlen( $ERRHEAD ) == 0 )
	{
		/**
		 * SOCIAL STUDIES
		 */
		$SECTION = 'SocialStudies';
		echo "\t\t<p>Exporting {$SECTION}...</p>\n";
		ob_flush();

		$output = drawSection( $SECTION, true );
		exportFile( $SECTION, $output );
	}

	if ( strlen( $ERRHEAD ) == 0 )
	{
		/**
		 * MATH AND SCIENCE
		 */
		$SECTION = 'MathAndScience';
		echo "\t\t<p>Exporting {$SECTION}...</p>\n";
		ob_flush();

		$output = drawSection( $SECTION, true );
		exportFile( $SECTION, $output );
	}

	if ( strlen( $ERRHEAD ) == 0 )
	{
		/**
		 * ZERO WEEK
		 */
		$SECTION = 'ZeroWeekAssessment';
		echo "\t\t<p>Exporting {$SECTION}...</p>\n";
		ob_flush();

		$output = drawSection( $SECTION, true );
		exportFile( $SECTION, $output );
	}

	if ( strlen( $ERRHEAD ) == 0 )
	{
		/**
		 * FIVE WEEK
		 */
		$SECTION = 'FiveWeekAssessment';
		echo "\t\t<p>Exporting {$SECTION}...</p>\n";
		ob_flush();

		$output = drawSection( $SECTION, true );
		exportFile( $SECTION, $output );
	}

	if ( strlen( $ERRHEAD ) == 0 )
	{
		/**
		 * TEN WEEK
		 */
		$SECTION = 'TenWeekAssessment';
		echo "\t\t<p>Exporting {$SECTION}...</p>\n";
		ob_flush();

		$output = drawSection( $SECTION, true );
		exportFile( $SECTION, $output );
	}

	if ( strlen( $ERRHEAD ) == 0 )
	{
		echo "\t\t<p>New CMS export created.</p>\n";
		echo "\t\t<p><a href=\"index.php\">Return to Chef Koochooloo Administration</a><p>\n";
		ob_flush();

		// DEBUG DRAW
		echo "\t\t<h2>Generated CMS Data</h2>\n";
		echo "\t\t<pre>";
		echo $output;
		echo "</pre>\n";
	}
	else
	{
		echo "\t\t<p class=\"indent error\">{$ERRHEAD}</p>\n";
		echo "\t\t<p><a href=\"index.php\">Return to Chef Koochooloo Administration</a><p>\n";

		echo "\t\t<h2>Error Details</h2>\n";
		echo "\t\t<pre>";
		echo $ERRMSG;
		echo "</pre>\n";
	}

	ob_end_flush(); 
?>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.2/jquery.min.js"></script>
		<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
	</body>
</html>
