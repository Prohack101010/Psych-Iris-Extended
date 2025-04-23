package scripting;

import openfl.Lib;
import flixel.input.keyboard.FlxKey;
import openfl.display.StageScaleMode;

#if windows import cpp.WindowsCPP; #end

class MainState extends MusicBeatState
{
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	
    override public function create()
    {
        #if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end
		
		#if windows WindowsCPP.setWindowLayered(); #end

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();
		
		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		
        // ClientPrefs.loadJsonPrefs();
        ClientPrefs.loadPrefs();

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

        super.create();

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

        MusicBeatState.switchState(new ScriptState('TitleState'));

        ScriptingVars.engineVersion = MainMenuState.psychExtendedVersion.trim();

		#if CHECK_FOR_UPDATES
		if (ClientPrefs.data.checkForUpdates) 
        {
			trace('Checking for Update...');

			var http = new haxe.Http("https://raw.githubusercontent.com/28AloneDark53/Psych-Extended/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				ScriptingVars.onlineVersion = data.split('\n')[0].trim();

				trace('Current Version: ' + ScriptingVars.onlineVersion);
                trace('Your Version: ' + ScriptingVars.engineVersion);

				if (ScriptingVars.onlineVersion != ScriptingVars.engineVersion) 
                {
                    trace('Versions aren\'t matching!');
                    
					ScriptingVars.outdated = true;
				}
			}

			http.onError = function (error) {
				trace('Error: $error');
			}

			http.request();
		}
		#end
		
		#if !PsychExtended_Extras
		ResetPsychExtendedExtras();
		#end
    }
	
	function ResetPsychExtendedExtras()
	{
	    //Use `if` for Fix TitleState Lag
	    if (ClientPrefs.data.FreeplayStyle != 'Psych')
	        ClientPrefs.data.FreeplayStyle = 'Psych';
	    if (ClientPrefs.data.MainMenuStyle != '1.0')
    	    ClientPrefs.data.MainMenuStyle = '1.0';
    	if (ClientPrefs.data.PauseMenuStyle != 'Psych')
    	    ClientPrefs.data.PauseMenuStyle = 'Psych';
    	if (ClientPrefs.data.TransitionStyle != 'Psych')
    	    ClientPrefs.data.TransitionStyle = 'Psych';
    	if (ClientPrefs.data.FPSCounter != 'Psych')
    	    ClientPrefs.data.FPSCounter = 'Psych';
    	if (ClientPrefs.data.DisableIntroVideo != true)
    	    ClientPrefs.data.DisableIntroVideo = true;
    	if (ClientPrefs.data.FreakyMenu != 'Psych')
    	    ClientPrefs.data.FreakyMenu = 'Psych';
    	if (ClientPrefs.data.NoteSkin != 'original')
    	    ClientPrefs.data.NoteSkin = 'original';
	}
}