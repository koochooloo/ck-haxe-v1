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

package com.firstplayable.hxlib.audio;

import com.firstplayable.hxlib.audio.Bus;
import haxe.ds.StringMap;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

using com.firstplayable.hxlib.utils.Utils;
using com.firstplayable.hxlib.StdX;
using Std;

class VolumeManager
{
	private var m_pVolumes:StringMap<VolumeInfo>;
	private var m_pVolumeMods:StringMap<Float>;
	private var m_pAudioManager:Audio;
	private var m_pChannelToBusMap:Array<Array<String>>;
	
	public function new( audioManager:Audio ) 
	{
		m_pVolumes = new StringMap<VolumeInfo>();
		m_pAudioManager = audioManager;
	}
	
	// -------------------- audio namespaced functions --------------------------------------
	
	@:allow( com.firstplayable.hxlib.audio )
	private function getVolumeToPlay( obj:AudioObject ):Float
	{
		if ( obj.isNull() )
		{
			// ERROR RETURN
			return Math.NaN;
		}
		
		var isMuted:Bool = false;
		var volume:Float = obj.defaultVolume;
		var busName:String = obj.bus;
		
		var profile:VolumeInfo;
		var profileVolume:Float;
		var profileNames:Array<String> = [ VolumeInfo.TYPE_ALL, busName, obj.id ];
		for ( name in profileNames )
		{
			profile = m_pVolumes.get( name );
			if ( profile.isValid() )
			{
				isMuted = profile.isMuted;
				if ( isMuted )
				{
					// NORMAL RETURN
					return Audio.MIN_VOLUME;
				}
				
				profileVolume = profile.volume;
				if ( !Math.isNaN( profileVolume ) )
				{
					volume = profileVolume;
				}
			}
		}
		
		if ( m_pVolumeMods.isValid() && m_pVolumeMods.exists( busName ) )
		{
			volume *= m_pVolumeMods.get( busName );
		}
		
		return volume;
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function getVolume( id:String ):Float
	{
		var obj:AudioObject = m_pAudioManager.m_pAudioObjects.get( id );
		if ( obj.isValid() )
		{
			return obj.currentVolume;
		}
		return Math.NaN;
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function getDefaultVolume( id:String ):Float
	{
		var obj:AudioObject = m_pAudioManager.m_pAudioObjects.get( id );
		if ( obj.isValid() )
		{
			return obj.defaultVolume;
		}
		return Math.NaN;
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function setVolumeForSound( sfxId:String, volume:Float, onlyActive:Bool, isOverridable:Bool ):Void
	{
		var obj:AudioObject = m_pAudioManager.m_pActiveAudioObjects.get( sfxId );
		if ( obj.isNull() )
		{
			// EARLY RETURN
			return;
		}
		
		var busName:String = obj.bus;
		var canChangeVolume:Bool = checkAndSetVolumeProfile( sfxId, VolumeInfo.TYPE_SND, volume, isOverridable, onlyActive, busName );
		if ( !canChangeVolume )
		{
			// EARLY RETURN
			return;
		}
		
		obj.currentVolume = volume;
		setVolumeForChannel( obj.soundChannel, volume, obj.bus );
		
		var duplicates:Array<AudioObject> = m_pAudioManager.m_pDuplicates.get( sfxId );
		if ( duplicates.isValid() && duplicates.length > 0 )
		{
			for ( duplicatedObj in duplicates )
			{
				duplicatedObj.currentVolume = volume;
				setVolumeForChannel( duplicatedObj.soundChannel, volume, busName );
			}
		}
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function setVolumeForBus( busId:String, volume:Float, onlyActive:Bool, isOverridable:Bool ):Void
	{
		var canChangeVolume:Bool = checkAndSetVolumeProfile( busId, VolumeInfo.TYPE_BUS, volume, isOverridable, onlyActive );
		if ( !canChangeVolume )
		{
			// EARLY RETURN
			return;
		}
		
		var bus:Bus = m_pAudioManager.m_pBusses.get( busId );
		if ( bus.isValid() )
		{
			for ( obj in bus.activeSounds )
			{
				var sndProfile:VolumeInfo = m_pVolumes.get( obj.id );
				if ( sndProfile.isValid() && !sndProfile.isOverridable )
				{
					continue;
				}
				
				obj.currentVolume = volume;
				setVolumeForChannel( obj.soundChannel, volume, busId );
				// TODO: duplicates?
			}
		}
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function setVolumeForAll( volume:Float, onlyActive:Bool, isOverridable:Bool ):Void
	{
		var canChangeVolume:Bool = checkAndSetVolumeProfile( VolumeInfo.TYPE_ALL, VolumeInfo.TYPE_ALL, volume, isOverridable, onlyActive );
		if ( !canChangeVolume )
		{
			// EARLY RETURN
			return;
		}
		
		for ( channel in m_pAudioManager.m_pActiveSoundChannels.keys() )
		{
			var obj:AudioObject = m_pAudioManager.m_pActiveSoundChannels.get( channel );
			if ( obj.isValid() )
			{
				var sndProfile:VolumeInfo = m_pVolumes.get( obj.id );
				if ( sndProfile.isValid() && !sndProfile.isOverridable )
				{
					continue;
				}
				
				sndProfile = m_pVolumes.get( obj.bus );
				if ( sndProfile.isValid() && !sndProfile.isOverridable )
				{
					continue;
				}
			}
			
			obj.currentVolume = volume;
			setVolumeForChannel( channel, volume, obj.bus );
		}
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function isMutedSound( sfxId:String ):Bool
	{
		var profile:VolumeInfo = m_pVolumes.get( sfxId );
		if ( profile.isValid() && profile.isMuted )
		{
			return true;
		}
		
		return false;
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function muteSound( sfxId:String, onlyActive:Bool, isOverridable:Bool ):Void
	{
		var obj:AudioObject = m_pAudioManager.m_pActiveAudioObjects.get( sfxId );
		if ( obj.isValid() )
		{
			setVolumeForChannel( obj.soundChannel, 0 );
		}
		
		var duplicates:Array<AudioObject> = m_pAudioManager.m_pDuplicates.get( obj.id );
		if ( duplicates.isValid() && duplicates.length > 0 ) 
		{
			for ( duplicatedObj in duplicates )
			{
				setVolumeForChannel( duplicatedObj.soundChannel, 0 );
			}
		}
		
		if ( !onlyActive )
		{
			setMuteProfile( sfxId, VolumeInfo.TYPE_SND, isOverridable );
		}
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function unmuteSound( sfxId:String, onlyActive:Bool ):Void
	{
		var obj:AudioObject = m_pAudioManager.m_pActiveAudioObjects.get( sfxId );
		if ( obj.isNull() )
		{
			// ERROR RETURN
			return;
		}
		
		var canUnmute:Bool = checkAndUnmuteProfile( sfxId, VolumeInfo.TYPE_SND, onlyActive, obj.bus );
		if ( !canUnmute )
		{
			// EARLY RETURN
			return;
		}
		
		setVolumeForChannel( obj.soundChannel, obj.currentVolume, obj.bus );
		
		var duplicates:Array<AudioObject> = m_pAudioManager.m_pDuplicates.get( obj.id );
		if ( duplicates.isValid() && duplicates.length > 0 )
		{
			for ( duplicatedObj in duplicates )
			{
				setVolumeForChannel( duplicatedObj.soundChannel, duplicatedObj.currentVolume, obj.bus );
			}
		}
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function muteBus( busId:String, onlyActive:Bool, isOverridable:Bool ):Void
	{
		var bus:Bus = m_pAudioManager.m_pBusses.get( busId );
		if ( bus.isValid() )
		{
			for ( obj in bus.activeSounds )
			{
				setVolumeForChannel( obj.soundChannel, 0 );
			}
		}
		
		if ( !onlyActive )
		{
			setMuteProfile( busId, VolumeInfo.TYPE_BUS, isOverridable );
		}
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function unmuteBus( busId:String, onlyActive:Bool ):Void
	{
		var canUnmute:Bool = checkAndUnmuteProfile( busId, VolumeInfo.TYPE_BUS, onlyActive );
		if ( !canUnmute )
		{
			// EARLY RETURN
			return;
		}
		
		var bus:Bus = m_pAudioManager.m_pBusses.get( busId );
		if ( bus.isValid() )
		{
			for ( obj in bus.activeSounds )
			{
				var sndProfile:VolumeInfo = m_pVolumes.get( obj.id );
				if ( sndProfile.isValid() && sndProfile.isMuted && !sndProfile.isOverridable )
				{
					continue;
				}
				setVolumeForChannel( obj.soundChannel, obj.currentVolume, busId );
			}
		}
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function isMutedBus( busId:String ):Bool
	{
		var sndProfile:VolumeInfo = m_pVolumes.get( busId );
		if ( sndProfile.isValid() )
		{
			return sndProfile.isMuted;
		}
		return false;
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function muteAll( onlyActive:Bool, isOverridable:Bool ):Void
	{
		for ( channel in m_pAudioManager.m_pActiveSoundChannels.keys() )
		{
			setVolumeForChannel( channel, 0 );
		}
		
		if ( !onlyActive )
		{
			setMuteProfile( VolumeInfo.TYPE_ALL, VolumeInfo.TYPE_ALL, isOverridable );
		}
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function unmuteAll( onlyActive:Bool ):Void
	{
		var canUnmute:Bool = checkAndUnmuteProfile( VolumeInfo.TYPE_ALL, VolumeInfo.TYPE_ALL, onlyActive );
		if ( !canUnmute )
		{
			// EARLY RETURN
			return;
		}
		
		for ( obj in m_pAudioManager.m_pActiveAudioObjects )
		{
			var sndProfile:VolumeInfo = m_pVolumes.get( obj.id );
		}
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function isMutedAll():Bool
	{
		var sndProfile:VolumeInfo = m_pVolumes.get( VolumeInfo.TYPE_ALL );
		if ( sndProfile.isValid() )
		{
			return sndProfile.isMuted;
		}
		return false;
	}
	
	// --------------------------------------------------------------------------------------
	
	private function checkAndSetVolumeProfile( id:String, type:String, volume:Float, isOverridable:Bool, onlyActive:Bool, busName:String = "" ):Bool
	{
		var profile:VolumeInfo = m_pVolumes.get( id );
		if ( profile.isValid() )
		{
			if ( !onlyActive && !Math.isNaN( profile.volume ) )
			{
				profile.volume = volume;
				profile.isOverridable = isOverridable;
			}
			else if ( profile.isMuted )
			{
				// NORMAL RETURN
				return false;
			}
		}
		else
		{
			if ( type == VolumeInfo.TYPE_SND || type == VolumeInfo.TYPE_BUS )
			{
				profile = m_pVolumes.get( busName );
				if ( !isVolumeOverridable( profile ) )
				{
					// NORMAL RETURN
					return false;
				}
			}
			
			if ( type == VolumeInfo.TYPE_BUS )
			{
				findAndDeleteOverriddenSound( id );
			}
			else if ( type == VolumeInfo.TYPE_ALL )
			{
				findAndDeleteOverriddenProfile();
			}
			
			if ( !onlyActive )
			{
				profile = new VolumeInfo( id, type, volume, VolumeInfo.NO_MUTE_FLAG, isOverridable );
				m_pVolumes.set( id, profile );
			}
		}
		
		return true;
	}
	
	private function findAndDeleteOverriddenSound( busName:String ):Void
	{
		for ( profile in m_pVolumes )
		{
			if ( profile.type == VolumeInfo.TYPE_SND && profile.isOverridable )
			{
				if ( m_pAudioManager.getBusForSound( profile.id ) == busName )
				{
					m_pVolumes.remove( profile.id );
				}
			}
		}
	}
	
	private function findAndDeleteOverriddenProfile():Void
	{
		for ( profile in m_pVolumes ) 
		{
			if ( profile.type != VolumeInfo.TYPE_ALL && profile.isOverridable )
			{
				m_pVolumes.remove( profile.id );
			}
		}
	}
	
	private function isVolumeOverridable( profile:VolumeInfo ):Bool
	{
		var isOverridable:Bool = true;
		if ( profile.isValid() )
		{
			var isMuted:Bool = profile.isMuted;
			var canChangeVolume:Bool = Math.isNaN( profile.volume ) || profile.isOverridable;
			isOverridable = !isMuted && canChangeVolume;
		}
		return isOverridable;
	}
	
	private function findAndDeleteMuteSound( busName:String ):Void
	{
		for ( sndProfile in m_pVolumes )
		{
			if ( sndProfile.isMuted && sndProfile.type != VolumeInfo.TYPE_ALL && sndProfile.isOverridable )
			{
				if ( Math.isNaN( sndProfile.volume ) )
				{
					m_pVolumes.remove( sndProfile.id );
				}
				else
				{
					sndProfile.isMuted = false;
				}
			}
		}
	}
	
	private function findAndDeleteMuteProfile():Void
	{
		for ( sndProfile in m_pVolumes )
		{
			if ( sndProfile.isMuted && sndProfile.type != VolumeInfo.TYPE_ALL && sndProfile.isOverridable )
			{
				if ( Math.isNaN( sndProfile.volume ) )
				{
					m_pVolumes.remove( sndProfile.id );
				}
				else
				{
					sndProfile.isMuted = false;
				}
			}
		}
	}
	
	private function setMuteProfile( id:String, type:String, isOverridable:Bool ):Void
	{
		var sndProfile:VolumeInfo = m_pVolumes.get( id );
		if ( sndProfile.isValid() )
		{
			sndProfile.isMuted = true;
		}
		else
		{
			sndProfile = new VolumeInfo( id, type, Math.NaN, VolumeInfo.MUTE_FLAG, isOverridable );
			m_pVolumes.set( id, sndProfile );
		}
	}
	
	private function checkAndUnmuteProfile( id:String, type:String, onlyActive:Bool, busName:String = "" ):Bool
	{
		var sndProfile:VolumeInfo;
		var canUnmute:Bool = true;
		if ( type == VolumeInfo.TYPE_SND )
		{
			sndProfile = m_pVolumes.get( id );
			if ( sndProfile.isValid() )
			{
				canUnmute = canUnmute && sndProfile.isOverridable;
			}
		}
		if ( type == VolumeInfo.TYPE_SND || type == VolumeInfo.TYPE_BUS )
		{
			sndProfile = m_pVolumes.get( id );
			if ( sndProfile.isValid() )
			{
				canUnmute = canUnmute && sndProfile.isOverridable;
			}
		}
		
		if (  canUnmute && !onlyActive )
		{
			sndProfile = m_pVolumes.get( id );
			if ( sndProfile.isValid() )
			{
				if ( Math.isNaN( sndProfile.volume ) )
				{
					sndProfile = null;
					m_pVolumes.remove( id );
				}
				else
				{
					sndProfile.isMuted = false;
				}
			}
		}
		
		if ( type == VolumeInfo.TYPE_BUS )
		{
			findAndDeleteMuteSound( id );
		}
		else if ( type == VolumeInfo.TYPE_ALL )
		{
			findAndDeleteMuteProfile();
		}
		
		
		return canUnmute;
	}
	
	private function setVolumeForChannel( channel:SoundChannel, volume:Float, busName:String = "" ):Void
	{
		if ( m_pVolumeMods.isValid() && m_pVolumeMods.exists( busName ) )
		{
			volume *= m_pVolumeMods.get( busName );
		}
		
		if ( channel.isValid() )
		{
			channel.soundTransform = new SoundTransform( volume );
		}
	}
}