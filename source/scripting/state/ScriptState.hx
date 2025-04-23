package scripting.state;

import openfl.utils.Assets as OpenFlAssets;
import flixel.util.FlxSave;

import options.*;
import editors.*;

import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;

#if VIDEOS_ALLOWED
import vlc.MP4Handler as VideoHandler;
#end

#if LUA_ALLOWED
import psychlua.*;
#end

#if SCRIPTING_ALLOWED
import scripting.substate.HScript.HScriptInfos;
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
import scripting.state.HScript as HScript;
import scripting.substate.ScriptSubstate;
#end

#if SCRIPTING_ALLOWED
class ScriptState extends MusicBeatState
{
	public static var targetFileName:String; 
	
	#if HXVIRTUALPAD_ALLOWED
	public var _hxvirtualpad:FlxVirtualPad;
	#end

	public function new(scriptName:String) 
	{
		super();

		targetFileName = scriptName;
	}
	
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();

	public static var instance:ScriptState;

	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;

	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, FlxText> = new Map<String, FlxText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();

	public var hscriptArray:Array<HScript> = [];

	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();

	var keysPressed:Array<Int> = [];
	private var keysArray:Array<String>;

	public var camGame:FlxCamera;

	override public function create()
	{
		Paths.clearUnusedMemory();
		
		camGame = initPsychCamera();

		instance = this;

		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		add(luaDebugGroup);

		Iris.warn = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(WARN, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			if (newPos.showLine == true) {
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			ScriptState.instance.addTextToDebug('WARNING: $msgInfo', FlxColor.YELLOW);
		}
		Iris.error = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(ERROR, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			if (newPos.showLine == true) {
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			ScriptState.instance.addTextToDebug('ERROR: $msgInfo', FlxColor.RED);
		}
		Iris.fatal = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(FATAL, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			if (newPos.showLine == true) {
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			ScriptState.instance.addTextToDebug('FATAL: $msgInfo', 0xFFBB0000);
		}

		startHScriptsNamed('custom_states/' + targetFileName + '.hx');
		startHScriptsNamed('custom_states/global.hx');

		callOnScripts('onCreatePost');

		super.create();
	}

	override public function update(elapsed:Float)
	{
		callOnScripts('onUpdate', [elapsed]);

		/* This shit doesn't fix Music, it breaks the game instead.
		if (FlxG.sound.music != null && FlxG.sound.music.looped) FlxG.sound.music.onComplete = fixMusic.bind();
		*/

		callOnScripts('onUpdatePost', [elapsed]);

		super.update(elapsed);
	}

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		super.stepHit();

		if(curStep >= lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		if(lastBeatHit >= curBeat) {
			return;
		}

		super.beatHit();

		lastBeatHit = curBeat;

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}

	var lastSectionHit:Int = -1;

	override function sectionHit()
	{
		if (lastSectionHit >= curSection)
		{
			return;
		}

		super.sectionHit();

		setOnScripts('curSection', curSection);
		callOnScripts('onSectionHit');
	}

	function fixMusic()
	{
		MusicBeatState.instance.resetMusicVars();
		
		lastStepHit = -1;
		lastBeatHit = -1;
		lastSectionHit = -1;
	}

	public function addTextToDebug(text:String, color:FlxColor) 
	{
		//fox
		var newText:DebugLuaText = luaDebugGroup.recycle(DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);

		Sys.println(text);
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite
		return variables.get(tag);

	public static var inCutscene:Bool;

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			return;
		}

		var video:VideoHandler = new VideoHandler();
			#if (hxCodec >= "3.0.0")
			// Recent versions
			video.play(filepath);
			video.onEndReached.add(function()
			{
				video.dispose();
				inCutscene = false;
				return;
			}, true);
			#else
			// Older versions
			video.playVideo(filepath);
			video.finishCallback = function()
			{
				inCutscene = false;
				return;
			}
			#end
		#else
		FlxG.log.warn('Platform not supported!');
		return;
		#end
	}

	override function destroy() {
		instance = null;

		for (script in hscriptArray)
			if(script != null)
			{
				if(script.exists('onDestroy')) script.call('onDestroy');
				script.destroy();
			}

		hscriptArray = null;

		super.destroy();
		#if HXVIRTUALPAD_ALLOWED
		if (_hxvirtualpad != null)
			_hxvirtualpad = FlxDestroyUtil.destroy(_hxvirtualpad);
		#end
	}

	public function startHScriptsNamed(scriptFile:String)
	{
		#if MODS_ALLOWED
		var scriptToLoad:String = Paths.modFolders('scripts/' + scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getScriptPath(scriptFile);
		#else
		var scriptToLoad:String = Paths.getScriptPath(scriptFile);
		#end

		if(FileSystem.exists(scriptToLoad))
		{
			if (Iris.instances.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public function initHScript(file:String)
	{
		var newScript:HScript = null;
		try
		{
			(newScript = new HScript(null, file)).setParent(this);
			if (newScript.exists('onCreate')) newScript.call('onCreate');
			trace('initialized hscript interp successfully: $file');
			hscriptArray.push(newScript);
		}
		catch(e:IrisError)
		{
			var pos:HScriptInfos = cast {fileName: file, showLine: false};
			Iris.error(Printer.errorToString(e, false), pos);
			var newScript:HScript = cast (Iris.instances.get(file), HScript);
			if(newScript != null)
				newScript.destroy();
		}
	}

	public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [FunkinLua.Function_Continue];

		var result:Dynamic = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;

		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(FunkinLua.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;

		for(script in hscriptArray)
		{
			@:privateAccess
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var callValue = script.call(funcToCall, args);
			if(callValue != null)
			{
				var myValue:Dynamic = callValue.returnValue;

				if((myValue == FunkinLua.Function_StopHScript || myValue == FunkinLua.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
				{
					returnVal = myValue;
					break;
				}

				if(myValue != null && !excludeValues.contains(myValue))
					returnVal = myValue;
			}
		}

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			script.set(variable, arg);
		}
	}

	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.data.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (MODS_ALLOWED && !flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'shaders/'))
		{
			var frag:String = folder + name + '.frag';
			var vert:String = folder + name + '.vert';
			var found:Bool = false;
			if(FileSystem.exists(frag))
			{
				frag = File.getContent(frag);
				found = true;
			}
			else frag = null;

			if(FileSystem.exists(vert))
			{
				vert = File.getContent(vert);
				found = true;
			}
			else vert = null;

			if(found)
			{
				runtimeShaders.set(name, [frag, vert]);
				//trace('Found shader $name!');
				return true;
			}
		}
		addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		#end
		return false;
	}

	public function switchToScriptState(name:String, ?doTransition:Bool = true)
	{
		FlxTransitionableState.skipNextTransIn = !doTransition;
		FlxTransitionableState.skipNextTransOut = !doTransition;

		MusicBeatState.switchState(new ScriptState(name));
	}

	public function resetScriptState(?doTransition:Bool = false)
	{
		switchToScriptState(targetFileName, doTransition);
	}

	public function openScriptSubState(subState:String)
	{
		openSubState(new ScriptSubstate(subState));
	}

	#if HXVIRTUALPAD_ALLOWED
	public function addHxVirtualPad(DPad:String, Action:String)
	{
		if (_hxvirtualpad != null)
			removeHxVirtualPad();

		_hxvirtualpad = new FlxVirtualPad(DPad, Action);
		add(_hxvirtualpad);

		controls.setVirtualPadUI(_hxvirtualpad, DPad, Action);
		trackedinputsUI = controls.trackedInputsUI;
		controls.trackedInputsUI = [];
		_hxvirtualpad.alpha = ClientPrefs.data.VirtualPadAlpha;
	}

	public function addHxVirtualPadCamera()
	{
		var camcontrol = new flixel.FlxCamera();
		camcontrol.bgColor.alpha = 0;
		FlxG.cameras.add(camcontrol, false);
		_hxvirtualpad.cameras = [camcontrol];
	}

	public function removeHxVirtualPad()
	{
		if (trackedinputsUI.length > 0)
			controls.removeVirtualControlsInput(trackedinputsUI);

		if (_hxvirtualpad != null)
			remove(_hxvirtualpad);
	}

	public static function checkVPadPress(buttonPostfix:String, type = 'justPressed') {
		var buttonName = "button" + buttonPostfix;
		var button = Reflect.getProperty(ScriptState.instance._hxvirtualpad, buttonName); //Access Spesific HxVirtualPad Button
		return Reflect.getProperty(button, type);
		return false;
	}
	#end
}
#else
class ScriptState extends MusicBeatState
{
	public function new(scriptName:String)
	{
		super();
	}
}
#end