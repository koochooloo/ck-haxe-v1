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

package com.firstplayable.hxlib.display;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import haxe.ds.StringMap;
import org.zamedev.particles.ParticleSystem;
import org.zamedev.particles.loaders.PixiParticleLoader;
import org.zamedev.particles.renderers.ParticleSystemRenderer;
import org.zamedev.particles.renderers.SpritesParticleRenderer;
#if ( openfl < "4.0.0" )
import org.zamedev.particles.renderers.DrawTilesParticleRenderer;
#end

#if !("zame-particles")
#error "haxelib 'zame-particles' is not installed."
#end

class PixiParticleViewer
{
	// map of vfx pools
	private static var m_particleEffects:StringMap<Array<ParticleSystem>> = new StringMap();
	// the particle renderer
	private static var m_particleRender:ParticleSystemRenderer =
		// openfl.TileMap was removed in openfl 4.0+, breaking DrawTilesParticleRenderer
		// TODO: once zame-particles updates to use new tile render system, we can clean
		//       this up and default to DrawTilesParticleRenderer
		#if ( openfl < "4.0.0" )
			new DrawTilesParticleRenderer();
		#else
			new SpritesParticleRenderer();
		#end
	
	/**
	 * Enables particles for rendering.
	 */
	public static function show():Void
	{
		GameDisplay.attach( LayerName.FOREGROUND, cast m_particleRender );
	}
	
	/**
	 * Disables particles from rendering.
	 */
	public static function hide():Void
	{
		GameDisplay.remove( LayerName.FOREGROUND, cast m_particleRender );
	}
	
	/**
	 * Registers a particle system.
	 * @param	type	Particle system name.
	 */
	// TODO: add max param to block infinite instances
	public static function allow( type:String ):Void
	{
		// check if already registered
		if ( !m_particleEffects.exists( type ) )
		{
			var vfx:ParticleSystem = create( type );
			
			// if we failed to load then don't register (will block future emit calls)
			if( vfx != null )
				m_particleEffects.set( type, [ vfx ] );
		}
		else
		{
			Debug.log( "Particle system '" + type + "' already registered." );
		}
	}
	
	/**
	 * Removes all particle systems of type 'name'.
	 * @param	type	Particle system name.
	 */
	public static function remove( type:String ):Void
	{
		// check if registered
		if ( m_particleEffects.exists( type ) )
		{
			var psPool:Array<ParticleSystem> = m_particleEffects.get( type );
			
			// stop all instances of particle type and remove from renderer
			for ( ps in psPool )
			{
				ps.stop();
				// TODO: addPS/removePS would be better to happen on ps.emit / ps.stop instead of create/remove
				m_particleRender.removeParticleSystem( ps );
			}
			
			// clean psPool from map
			m_particleEffects.remove( type );
		}
		else
		{
			Debug.log( "Cannot remove particle system '" + type + "' - does not exist." );
		}
	}
	
	/**
	 * Gets an instance particle system of type.
	 * @usage ParticleViewer.get( "ParticleName" ).emit( x, y );
	 * @param	type	Particle system name.
	 */
	public static function get( type:String ):ParticleSystem
	{
		var availablePS:ParticleSystem = null;
		
		// check if registered
		if ( m_particleEffects.exists( type ) )
		{
			var psPool:Array<ParticleSystem> = m_particleEffects.get( type );
			
			// find a free particle system that's not in use
			for ( ps in psPool )
			{
				if ( !ps.active )
				{
					availablePS = ps;
					break;
				}
			}
			
			// couldn't find one
			if ( availablePS == null )
			{
				availablePS = create( type );
				psPool.push( availablePS );
			}
		}
		else
		{
			Debug.log( "Cannot emit particle system '" + type + "' - does not exist." );
		}
		
		return availablePS;
	}
	
	/**
	 * Creates a new particle instance from a registered effect.
	 * @param	type
	 * @return
	 */
	private static function create( type:String ):ParticleSystem
	{
		var ps:ParticleSystem = PixiParticleLoader.load( "vfx/" + type + ".json", type );
		
		// add ps to renderer
		if( ps != null )
			m_particleRender.addParticleSystem( ps );
		else
			Debug.log( "Particle system '" + type + "' could not load!" );
		
		return ps;
	}
}