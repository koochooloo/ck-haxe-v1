//
// Copyright (C) 2017, 1st Playable Productions, LLC. All rights reserved.
//
// UNPUBLISHED -- Rights reserved under the copyright laws of the United
// States. Use of a copyright notice is precautionary only and does not
// imply publication or disclosure.
//
// THIS DOCUMENTATION CONTAINS CONFIDENTIAL AND PROPRIETARY INFORMATION
// OF 1ST PLAYABLE PRODUCTIONS, LLC. ANY DUPLICATION, MODIFICATION,
// DISTRIBUTION, OR DISCLOSURE IS STRICTLY PROHIBITED WITHOUT THE PRIOR
// EXPRESS WRITTEN PERMISSION OF 1ST PLAYABLE PRODUCTIONS, LLC.
///////////////////////////////////////////////////////////////////////////

package game.utils;

import parsihax.ParseObject;

using parsihax.Parser;

class TextParser
{
	// Matches a single asterisk
	private static var asterisk:ParseObject<String> = Parser.char("*");
	
	// Matches a single underscore
	private static var underscore:ParseObject<String> = Parser.char("_");
	
	// Ignore asterisks, underscores
	private static var text:ParseObject<String> = Parser.regexp(~/[^*_]+/);
	
	// Matches *text* replacing it with <b>text</b>
	private static var bold:ParseObject<String> = 
		asterisk.flatMap(function(_){
			return text.flatMap(function(text){
				return asterisk + Parser.succeed("<b>" + text + "</b>"); 
			});
		});
		
	// Matches _text_ replacing it with <em>text</em>
	private static var italics:ParseObject<String> = 
		underscore.flatMap(function(_){
			return text.flatMap(function(text){
				return underscore + Parser.succeed("<em>" + text + "</em>"); 
			});
		});
	
	// Matches bold, italics, or a single character
	private static var alternative:ParseObject<String> = 
		Parser.alt([bold, italics, Parser.any()]);
		
	// Recursively matches a block of text containing bold and italics
	public static var formattedText:ParseObject<String> = 
		Parser.lazy(function(){
			return alternative.flatMap(function(text){
				return Parser.alt([
					formattedText.flatMap(function(rest){
						return Parser.succeed(text + rest);
					}),
					Parser.succeed(text)
				]);
			});
		});
}