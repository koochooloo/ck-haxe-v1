package lime.tools.platforms;


import haxe.io.Path;
import haxe.Template;
import lime.tools.helpers.DeploymentHelper;
import lime.tools.helpers.FileHelper;
import lime.tools.helpers.HTML5Helper;
import lime.tools.helpers.IconHelper;
import lime.tools.helpers.LogHelper;
import lime.tools.helpers.ModuleHelper;
import lime.tools.helpers.PathHelper;
import lime.tools.helpers.ProcessHelper;
import lime.project.AssetType;
import lime.project.HXProject;
import lime.project.Icon;
import lime.project.PlatformTarget;
import sys.io.File;
import sys.FileSystem;


class HTML5Platform extends PlatformTarget {
	
	
	private var outputFile:String;
	
	
	public function new (command:String, _project:HXProject, targetFlags:Map<String, String> ) {
		
		super (command, _project, targetFlags);
		
		initialize (command, _project);
		
	}
	
	
	public override function build ():Void {
		
		ModuleHelper.buildModules (project, targetDirectory + "/obj", targetDirectory + "/bin");
		
		if (project.app.main != null) {
			
			var type = "release";
			
			if (project.debug) {
				
				type = "debug";
				
			} else if (project.targetFlags.exists ("final")) {
				
				type = "final";
				
			}
			
			var hxml = targetDirectory + "/haxe/" + type + ".hxml";
			ProcessHelper.runCommand ("", "haxe", [ hxml ] );
			
			if (noOutput) return;
			
			if (project.targetFlags.exists ("webgl")) {
				
				FileHelper.copyFile (targetDirectory + "/obj/ApplicationMain.js", outputFile);
				
			}
			
			if (project.modules.iterator ().hasNext ()) {
				
				ModuleHelper.patchFile (outputFile);
				
			}
			
			if (project.targetFlags.exists ("minify") || type == "final") {
				
				HTML5Helper.minify (project, targetDirectory + "/bin/" + project.app.file + ".js");
				
			}
			
		}
		
	}
	
	
	public override function clean ():Void {
		
		if (FileSystem.exists (targetDirectory)) {
			
			PathHelper.removeDirectory (targetDirectory);
			
		}
		
	}
	
	
	public override function deploy ():Void {
		
		DeploymentHelper.deploy (project, targetFlags, targetDirectory, "HTML5");
		
	}
	
	
	public override function display ():Void {
		
		var hxml = PathHelper.findTemplate (project.templatePaths, "html5/hxml/" + buildType + ".hxml");
		
		var context = project.templateContext;
		context.OUTPUT_DIR = targetDirectory;
		context.OUTPUT_FILE = outputFile;
		
		var template = new Template (File.getContent (hxml));
		
		Sys.println (template.execute (context));
		Sys.println ("-D display");
		
	}
	
	
	private function initialize (command:String, project:HXProject):Void {
		
		targetDirectory = PathHelper.combine (project.app.path, project.config.getString ("html5.output-directory", "html5/" + buildType));
		outputFile = targetDirectory + "/bin/" + project.app.file + ".js";
		
	}
	
	
	public override function run ():Void {
		
		HTML5Helper.launch (project, targetDirectory + "/bin");
		
	}
	
	
	public override function update ():Void {
		
		project = project.clone ();
		
		var destination = targetDirectory + "/bin/";
		PathHelper.mkdir (destination);
		
		var webfontDirectory = targetDirectory + "/obj/webfont";
		var useWebfonts = true;
		
		for (haxelib in project.haxelibs) {
			
			if (haxelib.name == "openfl-html5-dom" || haxelib.name == "openfl-bitfive") {
				
				useWebfonts = false;
				
			}
			
		}
		
		var fontPath;
		
		for (asset in project.assets) {
			
			if (asset.type == AssetType.FONT) {
				
				if (useWebfonts) {
					
					fontPath = PathHelper.combine (webfontDirectory, Path.withoutDirectory (asset.targetPath));
					
					if (!FileSystem.exists (fontPath)) {
						
						PathHelper.mkdir (webfontDirectory);
						FileHelper.copyFile (asset.sourcePath, fontPath);
						
						asset.sourcePath = fontPath;
						
						HTML5Helper.generateWebfonts (project, asset);
						
					}
					
					asset.sourcePath = fontPath;
					asset.targetPath = Path.withoutExtension (asset.targetPath);
					
				} else {
					
					project.haxeflags.push (HTML5Helper.generateFontData (project, asset));
					
				}
				
			}
			
		}
		
		if (project.targetFlags.exists ("xml")) {
			
			project.haxeflags.push ("-xml " + targetDirectory + "/types.xml");
			
		}
		
		if (LogHelper.verbose) {
			
			project.haxedefs.set ("verbose", 1);
			
		}
		
		ModuleHelper.updateProject (project);
		
		var libraryNames = new Map<String, Bool> ();
		
		for (asset in project.assets) {
			
			if (asset.library != null && !libraryNames.exists (asset.library)) {
				
				libraryNames[asset.library] = true;
				
			}
			
		}
		
		//for (library in libraryNames.keys ()) {
			//
			//project.haxeflags.push ("-resource " + targetDirectory + "/obj/manifest/" + library + ".json@__ASSET_MANIFEST__" + library);
			//
		//}
		
		//project.haxeflags.push ("-resource " + targetDirectory + "/obj/manifest/default.json@__ASSET_MANIFEST__default");
		
		var context = project.templateContext;
		
		context.WIN_FLASHBACKGROUND = project.window.background != null ? StringTools.hex (project.window.background, 6) : "";
		context.OUTPUT_DIR = targetDirectory;
		context.OUTPUT_FILE = outputFile;
		
		if (project.targetFlags.exists ("webgl")) {
			
			context.CPP_DIR = targetDirectory + "/obj";
			
		}
		
		context.favicons = [];
		
		var icons = project.icons;
		
		if (icons.length == 0) {
			
			icons = [ new Icon (PathHelper.findTemplate (project.templatePaths, "default/icon.svg")) ];
			
		}
		
		//if (IconHelper.createWindowsIcon (icons, PathHelper.combine (destination, "favicon.ico"))) {
			//
			//context.favicons.push ({ rel: "icon", type: "image/x-icon", href: "./favicon.ico" });
			//
		//}
		
		if (IconHelper.createIcon (icons, 192, 192, PathHelper.combine (destination, "favicon.png"))) {
			
			context.favicons.push ({ rel: "shortcut icon", type: "image/png", href: "./favicon.png" });
			
		}
		
		context.linkedLibraries = [];
		
		for (dependency in project.dependencies) {
			
			if (StringTools.endsWith (dependency.name, ".js")) {
				
				context.linkedLibraries.push (dependency.name);
				
			} else if (StringTools.endsWith (dependency.path, ".js") && FileSystem.exists (dependency.path)) {
				
				var name = Path.withoutDirectory (dependency.path);
				
				context.linkedLibraries.push ("./lib/" + name);
				FileHelper.copyIfNewer (dependency.path, PathHelper.combine (destination, PathHelper.combine ("lib", name)));
				
			}
			
		}
		
		for (asset in project.assets) {
			
			var path = PathHelper.combine (destination, asset.targetPath);
			
			if (asset.type != AssetType.TEMPLATE) {
				
				if (asset.type != AssetType.FONT) {
					
					PathHelper.mkdir (Path.directory (path));
					FileHelper.copyAssetIfNewer (asset, path);
					
				} else if (useWebfonts) {
					
					PathHelper.mkdir (Path.directory (path));
					var ext = "." + Path.extension (asset.sourcePath);
					var source = Path.withoutExtension (asset.sourcePath);
					
					for (extension in [ ext, ".eot", ".woff", ".svg" ]) {
						
						if (FileSystem.exists (source + extension)) {
							
							FileHelper.copyIfNewer (source + extension, path + extension);
							
						} else {
							
							LogHelper.warn ("Could not find generated font file \"" + source + extension + "\"");
							
						}
						
					}
					
				}
				
			}
			
		}
		
		FileHelper.recursiveCopyTemplate (project.templatePaths, "html5/template", destination, context);
		
		if (project.app.main != null) {
			
			FileHelper.recursiveCopyTemplate (project.templatePaths, "haxe", targetDirectory + "/haxe", context);
			FileHelper.recursiveCopyTemplate (project.templatePaths, "html5/haxe", targetDirectory + "/haxe", context, true, false);
			FileHelper.recursiveCopyTemplate (project.templatePaths, "html5/hxml", targetDirectory + "/haxe", context);
			
			if (project.targetFlags.exists ("webgl")) {
				
				FileHelper.recursiveCopyTemplate (project.templatePaths, "webgl/hxml", targetDirectory + "/haxe", context, true, false);
				
			}
			
		}
		
		for (asset in project.assets) {
			
			var path = PathHelper.combine (destination, asset.targetPath);
			
			if (asset.type == AssetType.TEMPLATE) {
				
				PathHelper.mkdir (Path.directory (path));
				FileHelper.copyAsset (asset, path, context);
				
			}
			
		}
		
	}
	
	
	@ignore public override function install ():Void {}
	@ignore public override function rebuild ():Void {}
	@ignore public override function trace ():Void {}
	@ignore public override function uninstall ():Void {}
	
	
}