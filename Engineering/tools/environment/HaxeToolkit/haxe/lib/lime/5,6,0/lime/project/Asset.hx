package lime.project;


import haxe.io.Path;
import lime.tools.helpers.FileHelper;
import lime.tools.helpers.ObjectHelper;
import lime.tools.helpers.StringHelper;
import lime.tools.helpers.PathHelper;
import lime.project.AssetType;
import sys.FileSystem;

@:access(lime.tools.helpers.FileHelper)


class Asset {
	
	
	public var data:Dynamic;
	public var embed:Null<Bool>;
	public var encoding:AssetEncoding;
	public var flatName:String;
	public var format:String;
	public var glyphs:String;
	public var id:String;
	public var library:String;
	//public var path:String;
	//public var rename:String;
	public var resourceName:String;
	public var sourcePath:String;
	public var targetPath:String;
	public var type:AssetType;
	
	
	public function new (path:String = "", rename:String = "", type:AssetType = null, embed:Null<Bool> = null, setDefaults:Bool = true) {
		
		if (!setDefaults) return;
		
		this.embed = embed;
		sourcePath = PathHelper.standardize (path);
		
		if (rename == "") {
			
			targetPath = path;
			
		} else {
			
			targetPath = rename;
			
		}
		
		id = targetPath;
		resourceName = targetPath;
		flatName = StringHelper.getFlatName (targetPath);
		format = Path.extension (path).toLowerCase ();
		glyphs = "32-255";
		
		if (type == null) {
			
			var extension = Path.extension (path);
			
			if (FileHelper.knownExtensions.exists (extension)) {
				
				this.type = FileHelper.knownExtensions.get (extension);
				
			} else {
				
				switch (extension.toLowerCase ()) {
					
					case "bundle":
						
						this.type = AssetType.MANIFEST;
					
					case "ogg", "m4a":
						
						if (FileSystem.exists (path)) {
							
							var stat = FileSystem.stat (path);
							
							//if (stat.size > 1024 * 128) {
							if (stat.size > 1024 * 1024) {
								
								this.type = AssetType.MUSIC;
								
							} else {
								
								this.type = AssetType.SOUND;
								
							}
							
						} else {
							
							this.type = AssetType.SOUND;
							
						}
					
					default:
						
						if (path != "" && FileHelper.isText (path)) {
							
							this.type = AssetType.TEXT;
							
						} else {
							
							this.type = AssetType.BINARY;
							
						}
					
				}
				
			}
			
		} else {
			
			this.type = type;
			
		}
		
	}
	
	
	public function clone ():Asset {
		
		var asset = new Asset ("", "", null, null, false);
		
		asset.data = data;
		asset.embed = embed;
		asset.encoding = encoding;
		asset.flatName = flatName;
		asset.format = format;
		asset.glyphs = glyphs;
		asset.id = id;
		asset.library = library;
		asset.resourceName = resourceName;
		asset.sourcePath = sourcePath;
		asset.targetPath = targetPath;
		asset.type = type;
		
		//ObjectHelper.copyFields (this, asset);
		
		return asset;
		
	}
	
	
}
