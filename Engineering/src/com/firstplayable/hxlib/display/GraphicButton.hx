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
import com.firstplayable.hxlib.utils.DeviceCapabilities;
import com.firstplayable.hxlib.utils.Utils;
import openfl.display.Bitmap;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
using com.firstplayable.hxlib.StdX;

enum GraphicButtonState
{
    UP;
    DOWN;
    OVER;
    OUT;
    DISABLED;
}

/**
 * An automated button class designed to work with bitmaps.
 * NOTE: MOUSE/ROLL_OVER/OUT ARE NOT IMPLEMENTED FOR Openfl v2!
 */
class GraphicButton extends OPSprite
{
    private static inline var INVALID_ID:Int = -1;
    
    /**
     * The display object to use for the up state. If set to null, a new sprite will be used.
     */
    public var upState( default, set ):Bitmap; // TODO BitmapData
    /**
     * The display object to use for the down state. Set as null to remove.
     */
    public var downState( default, set ):Bitmap;
    /**
     * The display object to use for the over state. Set as null to remove.
     */
    public var overState( default, set ):Bitmap;
    /**
     * The display object to use for the disabled state. Set as null to remove.
     */
    public var disabledState( default, set ):Bitmap;
    /**
     * The text field object to use as the button's label. Set as null to remove.
     */
    public var label( default, set ):TextField;
    /**
     * Sets whether the button is enabled. While not enabled, cannot recieve interaction or state changes.
     */
    public var enabled( default, set ):Bool;
    /**
     * Specify an id on construction that you can use to check which button was pressed. 
     */
    public var id( default, null ):Int;
    /**
     * Keeps track of last state.
     */
    private var m_curState:GraphicButtonState;
    /**
     * Alias isMobile result
     */
    private static var m_isMobile:Bool = DeviceCapabilities.isMobile();
    
    /**
     * Setter for upState property.
     * @param d
     * @return
     */
    private function set_upState( d:Bitmap ):Bitmap
    {
        if ( d == null )
            d = new Bitmap();
        
        //refresh state
        if ( m_curState == UP )
        {
            changeImage( d );
        }
        
        return upState = d;
    }

    /**
     * Setter for downState property.
     * @param d
     * @return
     */
    private function set_downState( d:Bitmap ):Bitmap
    {
        if ( d == null )
            d = upState;
        
        //refresh state
        if ( m_curState == DOWN )
        {
            changeImage( d );
        }
        
        return downState = d;
    }

    /**
     * Setter for overState property.
     * @param d
     * @return
     */
    private function set_overState( d:Bitmap ):Bitmap
    {
        if ( d == null )
            d = upState;
        
        //refresh state
        if ( m_curState == OVER )
        {
            changeImage( d );
        }
        
        return overState = d;
    }

    /**
     * Setter for disabledState property.
     * @param d
     * @return
     */
    private function set_disabledState( d:Bitmap ):Bitmap
    {
        if ( d == null )
            d = upState;
        
        //refresh state
        if ( m_curState == DISABLED )
        {
            changeImage( d );
        }
        
        return disabledState = d;
    }

    /**
     * Setter for label property.
     * @param t
     * @return
     */
    private function set_label( t:TextField ):TextField
    {
        if ( t != null )
        {
			addChild( t );
			
            t.mouseEnabled = false;
            t.width = upState.width;
            t.height = upState.height - t.y;
            t.multiline = true;
            t.wordWrap = false;
            t.autoSize = TextFieldAutoSize.LEFT;
            t.x = 0.5 * ( upState.width - t.textWidth );
            t.y = 0.5 * ( upState.height - t.textHeight );
        }
		else if ( label != null && label.parent == this )
		{
			label.parent.removeChild( label ); // TODO: won't remove old label?  (also needs to check for t==label)
		}
        
        return label = t;
    }

    /**
     * Setter for enabled property.
     * @param enable
     * @return
     */
    private function set_enabled( enable:Bool ):Bool
    {
        enable ? onEnable() : onDisable();
        return enabled = enable;
    }
    
    /**
     * Creates a new graphic button object. Button is automatically constructed and automated using the provided states, which can be changed at any time.
     * @param    ?up          Up state for the button.
     * @param    ?down        Down state for the button.
     * @param    ?over        Over state for the button.
     * @param    ?disabled    Disabled state for the button.
     * @param    ?labelField  A text field to use as a button label.
     * @param    ?onPressed   Callback for when the button is pressed.
     */
    public function new( ?up:Bitmap, ?down:Bitmap, ?over:Bitmap, ?disabled:Bitmap,
        ?labelField:TextField, ?onPressed:GraphicButton->Void, ?btnID:Int, ?bounds:SpriteBoxData )
    {
        super( null, bounds );
        
        upState = up;
        downState = validateButtonState( down );
        overState = validateButtonState( over );
        disabledState = disabled;
        label = labelField;
        
        id = ( btnID == null ) ? INVALID_ID : btnID;
        
        if( onPressed != null )
            onHit = onPressed;
        
		enabled = true;
			
        verify();
        onUp();
    }

    /**
     * Helper function for setting the button states. Prevents empty button states (flickering) when using Bitmaps for
     * button states, if a particular state does not have a valid asset. 
     * @param    state - the candidate button state to be validated
     * @return    null, if state is a Bitmap and its BitmapData is null; otherwise, returns state
     */
    private function validateButtonState( state:Bitmap ):Bitmap
    {
        var bitmap:Bitmap = state.as( Bitmap );
        
        if ( bitmap.isValid() && bitmap.bitmapData.isNull() )
        {
            return null;
        }
        
        return state;
    }

    /**
     * Verifies the button states.
     */
    private function verify():Void
    {
        if ( upState == null )       upState = new Bitmap();
        if ( downState == null )     downState = upState;
        if ( overState == null )     overState = upState;
        if ( disabledState == null ) disabledState = upState;
    }

    /**
     * Adds label to the button state.
     */
    private function addLabel():Void
    {
        if ( label != null )
            addChild( label );
    }
	
	public function setLabelText( text:String ):Void
	{
		if ( Debug.log_if( (label == null), "Can't set text on btn '" + name + "'; it doesn't have a label" ) )
		{
			// EARLY RETURN
			return;
		}
		
		label.text = text;
	}

    /**
     * Clears all listeners.
     */
    private function clearListeners():Void
    {
        Utils.safeRemoveListener( stage, MouseEvent.MOUSE_UP, onUp );
        Utils.safeRemoveListener( this, MouseEvent.MOUSE_DOWN, onDown );
		if (!m_isMobile)
		{
			Utils.safeRemoveListener( this, MouseEvent.MOUSE_OVER, onOver );
			Utils.safeRemoveListener( this, MouseEvent.MOUSE_MOVE, onMove );
			Utils.safeRemoveListener( this, MouseEvent.MOUSE_OUT, onOut );
		}
    }

    /**
     * Clears all graphics.
     */
    private function clearGraphics():Void
    {
        if ( upState.parent != null )                removeChild( upState );  // TODO BitmapData -- removeChild won't work after converting to BitmapData.  Not required in this case.
        if ( downState.parent != null )              removeChild( downState );
        if ( overState.parent != null )              removeChild( overState );
        if ( disabledState.parent != null )          removeChild( disabledState );
        if ( label != null && label.parent != null ) removeChild( label );
    }

    /**
     * Defines the up state behavior.
     * @param    e
     */
    private function onUp( e:MouseEvent = null ):Void
    {
        clearListeners();
        clearGraphics();
        
		changeImage( upState );
        addLabel();
        
		Utils.safeAddListener( this, MouseEvent.MOUSE_DOWN, onDown );
		if (!m_isMobile)
		{
			Utils.safeAddListener( this, MouseEvent.MOUSE_OVER, onOver );
			Utils.safeAddListener( this, MouseEvent.MOUSE_MOVE, onMove );
		}
		
		var prevState:GraphicButtonState = m_curState;
        m_curState = UP;
		
		// Explicitly called regardless of prior state
		onButtonUp( this );
		
		if ( prevState == DOWN
			&& (e != null)
			&& (e.target == this || e.target == null) )
        {
            trigger();
        }
    }

    /**
     * Defines the down state behavior.
     * @param    e
     */
    private function onDown( e:MouseEvent = null ):Void
    {
        clearListeners();
        clearGraphics();
        
		changeImage( downState );
        addLabel();
		
		Utils.safeAddListener( stage, MouseEvent.MOUSE_UP, onUp );
        
        m_curState = DOWN;
		
		// Explicitly called regardless of prior state
		onButtonDown( this );
    }
	
	 /**
     * Defines the over state behavior.
     * @param    e
     */
    private function onOver( e:MouseEvent = null ):Void
    {
		if (m_curState != OVER)
		{
			clearListeners();
			clearGraphics();
			
			changeImage( overState );
			addLabel();
			
			Utils.safeAddListener( this, MouseEvent.MOUSE_DOWN, onDown );
			if (!m_isMobile)
			{
				Utils.safeAddListener( this, MouseEvent.MOUSE_OUT, onOut );
			}
			
			m_curState = OVER;
			
			// Explicitly called regardless of prior state
			onButtonOver( this );
		}
    }
	
     /**
     * Defines the behavior when the mouse leaves the button
     * @param    e
     */
    private function onOut( e:MouseEvent = null ):Void
    {
		if (m_curState == OVER)
		{
			onButtonOut( this );
			
			// Return to the up state.
			onUp();
		}
    }
	
	/**
     * Defines the behavior when the mouse leaves the button
     * @param    e
     */
    private function onMove( e:MouseEvent = null ):Void
    {
		if (m_curState == UP)
		{
			onOver(e);
		}
    }
	
    /**
     * Defines the disabled state behavior.
     * @param    e
     */
    private function onDisable():Void
    {
        clearListeners();
        clearGraphics();
        
		changeImage( disabledState );
        addLabel();
        
        m_curState = DISABLED;
    }

    /**
     * Defines the re-enabled state behavior.
     * @param    e
     */
    private function onEnable():Void
    {
        onUp();
    }

    /**
     * Calls the trigger when the button is used.
     */
    private function trigger():Void
    {
        onHit( this );
    }
    
    /**
     * The trigger for when the button is used. Can be set to any function.
     * @param caller    the object that processed the event.
     */
    public dynamic function onHit( caller:GraphicButton ):Void
    {
#if HXLIB_GRAPHICBUTTON_LOG
        if ( label != null )
        {
            Debug.log( this + " \'" + label.text + "\' was hit!" );
        }
        else 
        {
            Debug.log( this + " was hit!" );
        }
#end // #if HXLIB_GRAPHICBUTTON_LOG
    }
    
    /**
     * The trigger for when the button is pressed (entering down state). Can be set to any function.
     * @param caller    the object that processed the event.
     */
    public dynamic function onButtonDown( caller:GraphicButton ):Void
    {
#if HXLIB_GRAPHICBUTTON_LOG
        if ( label != null )
        {
            Debug.log( this + " \'" + label.text + "\' was pressed!" );
        }
        else 
        {
            Debug.log( this + " was pressed!" );
        }
#end // #if HXLIB_GRAPHICBUTTON_LOG
    }
    
    /**
     * The trigger for when the button is released (entering up state). Can be set to any function.
     * @param caller    the object that processed the event.
     */
    public dynamic function onButtonUp( caller:GraphicButton ):Void
    {
#if HXLIB_GRAPHICBUTTON_LOG
        if ( label != null )
        {
            Debug.log( this + " \'" + label.text + "\' was released!" );
        }
        else 
        {
            Debug.log( this + " was released!" );
        }
#end // #if HXLIB_GRAPHICBUTTON_LOG
    }
	
	 /**
     * The trigger for when the button is hovered (entering over state). Can be set to any function.
     * @param caller    the object that processed the event.
     */
    public dynamic function onButtonOver( caller:GraphicButton ):Void
    {
#if HXLIB_GRAPHICBUTTON_LOG
        if ( label != null )
        {
            Debug.log( this + " \'" + label.text + "\' was hovered!" );
        }
        else 
        {
            Debug.log( this + " was hovered!" );
        }
#end // #if HXLIB_GRAPHICBUTTON_LOG
    }
	
	/**
     * The trigger for when the button is de-hovered (leaving over state). Can be set to any function.
     * @param caller    the object that processed the event.
     */
    public dynamic function onButtonOut( caller:GraphicButton ):Void
    {
#if HXLIB_GRAPHICBUTTON_LOG
        if ( label != null )
        {
            Debug.log( this + " \'" + label.text + "\' was de-hovered!" );
        }
        else 
        {
            Debug.log( this + " was de-hovered!" );
        }
#end // #if HXLIB_GRAPHICBUTTON_LOG
    }
}