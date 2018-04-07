//
// Copyright (C) 2006-2016, 1st Playable Productions, LLC. All rights reserved.
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
package com.firstplayable.hxlib.net.apis;

import js.Browser;

/**
 * Wrapper class for the Twitter javascript API.
 *
 */

class TwitterApi
{
	private static var BUTTON_ID:String = "tweet_btn";

	/**
	 * Access the window.twttr object created by Twitter API
	 */
	private static var twttr(get, null):Dynamic;

	/**
	 * Uses the Twitter web intent interface to open a new browser window
	 * and send a tweet.
	 *
	 * https://dev.twitter.com/web/tweet-button/web-intent
	 *
	 * @param text - pre-populated text of the tweet.
	 * @param url - Link to be included in the tweet.
	 * @param hashtags - comma separated list of hashtags
	 * @param via - Twitter username to attribute as the source of the tweet
	 * @param related - comma separated list of usernames
	 * @param inReplyTo - tweet id of a parent conversation
	 */
	public static function tweet( ?text:String, ?url:String, ?hashtags:String, ?via:String, ?related:String, ?inReplyTo:String, ?surveyRedirect:Bool = false, ?saveID:String )
	{
		var intent = 'https://twitter.com/intent/tweet?';

		if (text != null)
		{
			intent += "text=" + StringTools.urlEncode(text) + "&";
		}

		if (url != null)
		{
			intent += "url=" + StringTools.urlEncode(url) + "&";
		}

		if (hashtags != null)
		{
			intent += "hashtags=" + StringTools.urlEncode(hashtags) + "&";
		}

		if (via != null)
		{
			intent += "via=" + StringTools.urlEncode(via) + "&";
		}

		if (related != null)
		{
			intent += "related=" + StringTools.urlEncode(related) + "&";
		}

		if (inReplyTo != null)
		{
			intent += "inReplyTo=" + StringTools.urlEncode(inReplyTo) + "&";
		}

		// Twitter doesn't care if we have a trailing & or ?...

		if ( surveyRedirect )
		{
			intent = "survey.php?s=" + saveID + "&r=" + intent;
		}
		Browser.window.open(intent);
	}

	/**
	 * Creates a tweet button via Twitter's javascript api.
	 * This is kinda hacky, we're creating a raw html element in front
	 * of our canvas (and everything else).
	 *
	 * This button lives entirely outside of haxe-land and can only be
	 * destroyed by removeTweetBtn().
	 *
	 * @param x Percentage from the top pf the browser window.
	 * @param y Percentage from the left of the browser window.
	 * @param url Link to be included in the tweet.
	 * @param params Dynamic object containing various optional params:
	 *		text - pre-populated text of the tweet.
	 *		hashtags - comma separated list of hashtags
	 *		via - Twitter username to attribute as the source of the tweet
	 *		related - comma separated list of usernames
	 *
	 * https://dev.twitter.com/web/tweet-button/parameters
	 */
	public static function createTweetBtn(x:Int, y:Int, url:String, params:Dynamic):Void
	{

		var div = Browser.window.document.createDivElement();
		div.style.position = "absolute";
		div.style.left = '$x%';
		div.style.top = '$y%';
		div.style.zIndex = "1000";
		div.id = BUTTON_ID;

		Browser.window.document.body.appendChild(div);

		params.size = "large";

		// Check to see if the twitter script has fully loaded.
		if (twttr.init == true)
		{
			twttr.widgets.createShareButton(url, div, params);
		}
		else
		{
			// If not we can enqueue a callback to fire once it has.
			twttr.ready(function(t) {
				t.widgets.createShareButton(url, div, params);
			});
		}
	}

	/**
	 * Removes the button created by the dark wizardry in createTweetBtn().
	 */
	public static function removeTweetBtn():Void
	{
		var div = Browser.window.document.getElementById(BUTTON_ID);

		if (div != null)
		{
			Browser.window.document.body.removeChild(div);
		}
	}

	/**
	 * Initialize window.twttr object if it doesn't exist.
	 */
	private static function get_twttr():Dynamic
	{
		var win:Dynamic = Browser.window;

		if (win.twttr == null)
		{
			init();
		}

		return win.twttr;
	}

	/**
	 * Load Twitter's widgets.js script and create the window.twttr object.
	 * Raw javascript from Twitter, see https://dev.twitter.com/web/javascript/loading
	 *
	 * Called automatically the first time twttr is used, but can be called
	 * manually as paranoia against slow load of the external script.
	 *
	 * The load is async, check twttr.init to see if it's ready.  
	 * If not, twttr.ready() will enque a function to call when it is.
	 * See creteTweetBtn() above for example usage.
	 */
	public static function init()
	{
		untyped window.twttr = (function(d, s, id) {
				var js, fjs = d.getElementsByTagName(s)[0], t = window.twttr || {};
				if (d.getElementById(id)) return t;
				js = d.createElement(s); js.id = id;
				js.src = "https://platform.twitter.com/widgets.js";
				fjs.parentNode.insertBefore(js, fjs);
				t._e = []; t.ready = function(f) { t._e.push(f); }; return t;
				}(document, 'script', 'twitter-wjs'));
	}
}


