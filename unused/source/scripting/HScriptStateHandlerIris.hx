package scripting;

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
#end

class HScriptStateHandler extends MusicBeatState
{
	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
    private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
    #end
    
    public static var instance:HScriptStateHandler;
    
    #if HSCRIPT_ALLOWED
	public var hscriptArray:Array<StateHScriptv3> = [];
	public var instancesExclude:Array<String> = [];
	#end
	
	#if HXVIRTUALPAD_ALLOWED
    public static var _hxvirtualpad:FlxVirtualPad;
    
    public static var dpadMode:Map<String, FlxDPadMode>;
	public static var actionMode:Map<String, FlxActionMode>;
	#end
	
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();	
	public static function getVariables()
		return getScriptingState().variables;
		
	public static function getScriptingState():HScriptStateHandler {
		var curState:Dynamic = FlxG.state;
		var leState:HScriptStateHandler = curState;
		return leState;
	}
	
	override function create()
	{
	    instance = this;
	    
	    #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		add(luaDebugGroup);
		#end
	    
	    #if HXVIRTUALPAD_ALLOWED
		// FlxDPadModes
		dpadMode = new Map<String, FlxDPadMode>();
		dpadMode.set("UP_DOWN", UP_DOWN);
		dpadMode.set("LEFT_RIGHT", LEFT_RIGHT);
		dpadMode.set("UP_LEFT_RIGHT", UP_LEFT_RIGHT);
		dpadMode.set("LEFT_FULL", FULL); //1.0 Support
		dpadMode.set("FULL", FULL);
		dpadMode.set("RIGHT_FULL", RIGHT_FULL);
		dpadMode.set("DUO", DUO);
		dpadMode.set("NONE", NONE);
			
		actionMode = new Map<String, FlxActionMode>();
		actionMode.set('E', E);
		actionMode.set('A', A);
		actionMode.set('B', B);
		actionMode.set('A_B', A_B);
		actionMode.set('A_B_C', A_B_C);
		actionMode.set('A_B_E', A_B_E);
		actionMode.set('A_B_E_C_M', A_B_E_C_M);
		actionMode.set('A_B_X_Y', A_B_X_Y);
		actionMode.set('B_X_Y', B_X_Y);
		actionMode.set('A_B_C_X_Y_Z', A_B_C_X_Y_Z);
		actionMode.set('FULL', FULL);
		actionMode.set('controlExtend', controlExtend);
		actionMode.set('NONE', NONE);
		#end

        super.create();
        
		callOnScripts('onCreatePost');
	}
	
	override function update(elapsed:Float)
	{
	    super.update(elapsed);
	    
		callOnScripts('onUpdatePost', [elapsed]);
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
	
	#if HXVIRTUALPAD_ALLOWED
	public function addHxVirtualPad(DPad:FlxDPadMode, Action:FlxActionMode)
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
		var button = Reflect.getProperty(HScriptStateHandler._hxvirtualpad, buttonName); //Access Spesific HxVirtualPad Button
		return Reflect.getProperty(button, type);
		return false;
	}
	#end
	
	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
    public function addTextToDebug(text:String, color:FlxColor) 
    {
        var newText:DebugLuaText = luaDebugGroup.recycle(DebugLuaText);
        newText.text = text;
        newText.color = color;
        newText.disableTime = 6;
        newText.alpha = 1;
        newText.setPosition(10, 8 - newText.height);
        newText.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
            spr.y += newText.height + 2;
        });
        luaDebugGroup.add(newText);

        Sys.println(text);
    }
    #end
    
    override function destroy() {
        instance = null;
        
		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				var ny:Dynamic = script.get('onDestroy');
				if(ny != null && Reflect.isFunction(ny)) ny();
				script.destroy();
			}

		hscriptArray = null;
		#end
		
		super.destroy();
		
		#if HXVIRTUALPAD_ALLOWED
		if (_hxvirtualpad != null)
			_hxvirtualpad = FlxDestroyUtil.destroy(_hxvirtualpad);
		#end
	}
	
	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String)
	{
		#if MODS_ALLOWED
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getSharedPath(scriptFile);
		#else
		var scriptToLoad:String = Paths.getSharedPath(scriptFile);
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
		var newScript:StateHScriptv3 = null;
		try
		{
			newScript = new StateHScriptv3(null, file);
			newScript.call('onCreate');
			trace('initialized hscript interp successfully: $file');
			hscriptArray.push(newScript);
		}
		catch(e:Dynamic)
		{
			addTextToDebug('ERROR ON LOADING ($file) - $e', FlxColor.RED);
			var newScript:StateHScriptv3 = cast (Iris.instances.get(file), StateHScriptv3);
			if(newScript != null)
				newScript.destroy();
		}
	}
	#end

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
		var returnVal:String = FunkinLua.Function_Continue;

		#if HSCRIPT_ALLOWED
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

			try
			{
				var callValue = script.call(funcToCall, args);
				var myValue:Dynamic = callValue.returnValue;

				if((myValue == FunkinLua.Function_StopHScript || myValue == FunkinLua.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
				{
					returnVal = myValue;
					break;
				}

				if(myValue != null && !excludeValues.contains(myValue))
					returnVal = myValue;
			}
			catch(e:Dynamic)
			{
				addTextToDebug('ERROR (${script.origin}: $funcToCall) - $e', FlxColor.RED);
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		//null
	}
}