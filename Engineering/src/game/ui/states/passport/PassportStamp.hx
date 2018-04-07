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

package game.ui.states.passport;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.display.anim.SpritesheetAnim;
import com.firstplayable.hxlib.loader.ResMan;
import game.def.PassportDefs;
import game.def.PassportDefs.StampStatus;
import game.events.PassportStampClaimedEvent;
import game.init.Display;
import game.ui.SpeckMenu;
import motion.Actuate;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;

/**
 * A single stamp in the passport book
 */
class PassportStamp extends SpeckMenu
{
	public static inline var MENU_NAME:String = "PassportStamp";
	
	//=============================================
	// Display Members
	//=============================================
	private var m_stamp:OPSprite;
	private var m_unlockBox:DisplayObjectContainer;
	
	private var m_weekText:TextField;
	private var m_countryText:TextField;
	
	private var m_stamper:DisplayObjectContainer;
	private var m_stampVfx:SpritesheetAnim;
	
	//=============================================
	// Data Members
	//=============================================
	private var m_idx:Int;
	private var m_country:String;
	
	public function new() 
	{
		super(MENU_NAME);
		
		m_stamp = getChildAs("spr_stamp", OPSprite);
		m_unlockBox = getChildAs("spr_unlock", DisplayObjectContainer);
		
		m_weekText = getChildAs("lbl_week", TextField);
		m_countryText = getChildAs("lbl_country", TextField);
		
		m_stamper = getChildAs("spr_stamper", DisplayObjectContainer);
		m_stampVfx = getChildAs("spr_stamper_vfx", SpritesheetAnim);
		
		m_idx = -1;
		m_country = null;
	}
	
	/**
	 * Sets the stamp up for the provided country.
	 * @param	countryName
	 */
	public function setup(stampIdx:Int, countryName:String):Void
	{
		m_idx = stampIdx;
		m_country = countryName;
		
		var status:StampStatus = SpeckGlobals.saveProfile.passportStamps.get(countryName);
		if (status == null)
		{
			Debug.warn("no passport status data for: " + countryName);
			status = UNEARNED;
		}
		
		switch(status)
		{
			case UNEARNED:
			{
				m_stamp.visible = false;
				m_unlockBox.visible = false;
				m_weekText.visible = true;
				var weekNum:Int = stampIdx + 1;
				var weekText:String = "Week " + weekNum;
				m_weekText.text = weekText;
				m_countryText.visible = false;
				m_stamper.visible = false;
				m_stampVfx.visible = false;
			}
			case EARNED:
			{
				m_stamp.visible = false;
				m_unlockBox.visible = true;
				m_unlockBox.addEventListener(MouseEvent.MOUSE_DOWN, onClickToEarnStamp);
				m_weekText.visible = true;
				var weekNum:Int = stampIdx + 1;
				var weekText:String = "Week " + weekNum;
				m_weekText.text = weekText;
				m_countryText.visible = true;
				m_stamper.visible = false;
				m_stampVfx.visible = false;
			}
			case CLAIMED:
			{
				var stampAssetName:String = PassportDefs.STAMP_ASSET_PATH + PassportDefs.COUNTRY_STAMP_MAP.get(countryName);
				//TODO: does this need to come from the database???
				m_stamp.changeImage(ResMan.instance.getImage(stampAssetName));
				m_stamp.visible = true;
				m_unlockBox.visible = false;
				m_weekText.visible = false;
				m_countryText.visible = false;
				m_stamper.visible = false;
				m_stampVfx.visible = false;
			}
		}
	}
	
	public function release():Void
	{
		m_unlockBox.removeEventListener(MouseEvent.MOUSE_DOWN, onClickToEarnStamp);
		removeEventListener(Event.ENTER_FRAME, updateStampVFX);
		Actuate.stop(m_stamper);
		Actuate.stop(m_stampVfx);
		Actuate.stop(m_stamp);
	}
	
	/**
	 * Handle earning a stamp
	 * @param	e
	 */
	private function onClickToEarnStamp(e:MouseEvent):Void
	{
		m_unlockBox.removeEventListener(MouseEvent.MOUSE_DOWN, onClickToEarnStamp);
		
		SpeckGlobals.saveProfile.updateStampStatus(m_country, CLAIMED);
		
		//===========================================
		// Handle Stamp VFX
		//===========================================
		WebAudio.instance.play("SFX/quiz_true_click_old");
		
		Actuate.tween(m_unlockBox, Tunables.STAMP_FADE_TIME, {alpha:0});
		
		m_stamper.visible = true;
		var stamperEndY:Float = m_stamper.y;
		m_stamper.y = -Tunables.STAMP_DROP_HEIGHT;

		m_stampVfx.visible = true;
		m_stampVfx.gotoAndPlay("2d/UI/passport/vfx_stamp", false);
		
		var dropTime:Float = cast(Tunables.STAMPER_DROP_FRAMES, Float) / 48.0;
		Actuate.tween(m_stamper, dropTime, {y: stamperEndY});
		
		addEventListener(Event.ENTER_FRAME, updateStampVFX);
	}
	
	/**
	 * Checks every frame if the vfx anim is done.
	 * @param	e
	 */
	private function updateStampVFX(e:Event):Void
	{
		if (!m_stamp.visible)
		{
			if (m_stampVfx.currentFrame >= Tunables.STAMPER_DROP_FRAMES)
			{
				//TODO: different sfx here?
				WebAudio.instance.play("SFX/recipe_click");
				
				m_countryText.visible = false;
				m_weekText.visible = false;
				
				var stampAssetName:String = PassportDefs.STAMP_ASSET_PATH + PassportDefs.COUNTRY_STAMP_MAP.get(m_country);
				//TODO: does this need to come from the database???
				m_stamp.changeImage(ResMan.instance.getImage(stampAssetName));
				
				m_stamp.alpha = 0;
				m_stamp.visible = true;
				
				Actuate.tween(m_stamp, Tunables.STAMP_APPEAR_TIME, {alpha:1.0});
				
				var waitFrames:Float = m_stampVfx.totalFrames - Tunables.STAMPER_DROP_FRAMES - Tunables.STAMPER_RAISE_FRAMES - 1;
				var waitTime:Float = waitFrames / 48.0;
				
				var raiseTime:Float = cast(Tunables.STAMPER_RAISE_FRAMES, Float) / 48.0;
				
				var finalY:Float = -Tunables.STAMP_DROP_HEIGHT;
				
				Actuate.stop(m_stamper);
				Actuate.tween(m_stamper, raiseTime, {y: finalY}, true).delay(waitTime);
			}
		}
		
		//isPlaying is not working T _ T
		if (m_stampVfx.currentFrame >= m_stampVfx.totalFrames - 1)
		{
			removeEventListener(Event.ENTER_FRAME, updateStampVFX);
			m_stampVfx.visible = false;
			m_stamper.visible = false;
			
			WebAudio.instance.play("SFX/quiz_true_click");
			
			SpeckGlobals.event.dispatchEvent(new PassportStampClaimedEvent(m_country));
		}
	}
}