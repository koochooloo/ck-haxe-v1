package lime.graphics.opengl.ext;


@:keep


#if (!js || !html5 || display)


class OES_element_index_uint {
	
	
	public var UNSIGNED_INT = 0x1405;
	
	
	private function new () {
		
		
		
	}
	
	
}


#else


@:native("OES_element_index_uint")
extern class OES_element_index_uint {
	
	
	
	
}


#end