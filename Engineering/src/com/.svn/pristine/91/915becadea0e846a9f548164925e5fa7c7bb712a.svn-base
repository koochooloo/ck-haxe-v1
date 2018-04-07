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
package com.firstplayable.hxlib.display.progress.fill;
import com.firstplayable.hxlib.utils.ColorUtils;
import com.firstplayable.hxlib.utils.MathUtils;
import openfl.display.Shape;

typedef RadialFillSettings =
{
    radius:Float,
    startFillColor:Int,
    ?endFillColor:Int,
    ?fillThickness:Float,
    ?fillAngle:Int
}

class RadialFill extends ShapeFill
{
    private var m_outerR:Float;  //outer circle radius
    private var m_innerR:Float;  //inner circle radius
    private var m_fill  :Shape;  //fill shape
    private var m_fillAngle:Int; //fill size
    private var m_fillColors:Array<Int>; //fill color
    
    /**
     * Creates a new radial fill object.
     * @param radius            The radius of the outside of the circle.
     * @param startFillColor    Color to fill the circle with.
     * @param ?endFillColor     Optional - circle will fill with a linear gradient from startFillColor to endFillColor;
     *                          if null, circle will solid fill with startFillColor.
     * @param ?fillThickness    Optional - circle will utilize a rainbow effect (cutout of center);
     *                          if null, entire circle will be filled.
     * @param fillAngle         Optional - controls the length of the fill, in degrees.
     * @param lineColor         Optional - color of the outline of the circle.
     * @param lineThickness     Optional - thickness of the outline of the circle.
     */
    public function new( p:RadialFillSettings )
    {
        super();
        
        if ( p.endFillColor == null )  p.endFillColor = p.startFillColor;
        if ( p.fillThickness == null ) p.fillThickness = p.radius;
        if ( p.fillAngle == null )     p.fillAngle = 360;
        
        m_outerR = p.radius;
        m_innerR = p.radius - p.fillThickness;
        m_fillColors = [ p.startFillColor, p.endFillColor ];
        m_fillAngle = p.fillAngle;
        fullLength = 2 * Math.PI * m_outerR;
        
        m_fill = new Shape();
        addChild( m_fill );
    }
    
    /**
     * 
     * @param t
     */
    override private function updateDraw( t:Float ):Void
    {
        fillLength = fullLength * t; //filled circumference
        var step:Int = Std.int( t * m_fillAngle );
        m_fill.graphics.clear();
        
        //break down color components to figure out spread
        var startRgb:Dynamic = ColorUtils.hexToArgb( m_fillColors[ 0 ] );
        var endRgb  :Dynamic = ColorUtils.hexToArgb( m_fillColors[ 1 ] );
        
        var lineRatio:Float = m_outerR / 60;
        
        var difR:Float = ( endRgb.r - startRgb.r ) / ( m_fillAngle * lineRatio );
        var difG:Float = ( endRgb.g - startRgb.g ) / ( m_fillAngle * lineRatio );
        var difB:Float = ( endRgb.b - startRgb.b ) / ( m_fillAngle * lineRatio );
        
        var colorStep:Int;
        var fromX :Float;
        var fromY :Float;
        var toX   :Float;
        var toY   :Float;
        var angRad:Float;
        
        //draw a line segment for each degree of fill
        var count:Int = Std.int( step * lineRatio ) + 1;
        for ( i in 0...count )
        {
            colorStep = m_fillColors[ 0 ] + ColorUtils.argbToHex( Std.int( difR * i ), Std.int( difG * i ), Std.int( difB * i ) );
            m_fill.graphics.lineStyle( 1, colorStep );
            
            angRad = i / lineRatio * MathUtils.RADIANS_MULTIPLIER;
            fromX = m_innerR  * Math.cos( angRad );
            fromY = -m_innerR * Math.sin( angRad );
            toX   = m_outerR  * Math.cos( angRad );
            toY   = -m_outerR * Math.sin( angRad );
            
            m_fill.graphics.moveTo( fromX, fromY );
            m_fill.graphics.lineTo( toX, toY );
        }
        
        m_fill.graphics.endFill();
    }
}