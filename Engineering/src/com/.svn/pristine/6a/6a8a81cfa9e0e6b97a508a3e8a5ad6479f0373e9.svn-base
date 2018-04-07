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
import openfl.display.GradientType;
import openfl.display.Shape;
import openfl.geom.Matrix;

typedef LinearFillSettings =
{
    width:Int,
    height:Int,
    startFillColor:Int,
    ?endFillColor:Int
}

class LinearFill extends ShapeFill
{
    private var m_size:Array<Int>; //width, height
    private var m_fill  :Shape;    //fill shape
    private var m_fillColors:Array<Int>; //fill color
    private var m_fillMtx:Matrix;
    
    public function new( p:LinearFillSettings ) 
    {
        super();
        
        if ( p.endFillColor == null ) p.endFillColor = p.startFillColor;
        m_fillColors = [ p.startFillColor, p.endFillColor ];
        m_size = [ p.width, p.height ];
        fullLength = p.width;
        
        m_fillMtx = new Matrix();
        m_fillMtx.createGradientBox( fullLength, 1, 0, 0, 0 );
        
        m_fill = new Shape();
        addChild( m_fill );
    }
    
    /**
     * 
     * @param t
     */
    override private function updateDraw( t:Float ):Void
    {
        m_fill.graphics.clear();
        
        fillLength = fullLength * t;
		
		//TODO: at last attempt, gradientFill was not working with openfl 2+ -jm
		#if ( openfl > "2.0.0" )
			m_fill.graphics.beginFill( m_fillColors[ 0 ] );
		#else
			m_fill.graphics.beginGradientFill( GradientType.LINEAR, m_fillColors, [ 100, 100 ], [ 0, 255 ], m_fillMtx );
		#end
		
        m_fill.graphics.drawRect( 0, 0, fillLength, m_size[ 1 ] );
        m_fill.graphics.endFill();
    }
}