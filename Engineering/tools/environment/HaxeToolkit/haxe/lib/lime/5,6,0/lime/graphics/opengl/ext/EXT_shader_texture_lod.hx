package lime.graphics.opengl.ext;


@:keep


#if (!js || !html5 || display)


class EXT_shader_texture_lod {
	
	
	private function new () {
		
		
		
	}
	
	
}


#else


@:native("EXT_shader_texture_lod")
extern class EXT_shader_texture_lod {
	
	
	
	
}


#end