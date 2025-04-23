import flixel.text.FlxText;
import flixel.text.FlxTextFormat;
import flixel.text.FlxTextFormatMarkerPair;
import extras.CustomSwitchState;
import tjson.TJSON as Json;
import Main;
import TitleState;

var skippedIntro:Bool = false;

var epicTexts:FlxText;

var logo:FlxSprite;
var gf:FlxSprite;
var titleText:FlxSprite;

function onCreate()
{
    //fix
    /* use global.hx for fix crashes
    var jsonToLoad:String = Paths.modFolders('data.json');
    if(!FileSystem.exists(jsonToLoad))
        jsonToLoad = Paths.getSharedPath('data.json');
    var jsonData = Json.parse(File.getContent(jsonToLoad));
    Conductor.bpm = Reflect.hasField(jsonData, 'bpm') ? jsonData.bpm : 102;
    */
    
    //main code
    epicTexts = new FlxText(0, 0, FlxG.width, '');
    epicTexts.setFormat(Paths.font('vcr.ttf'), 78, FlxColor.WHITE, 'center');
    add(epicTexts);
    epicTexts.antialiasing = ClientPrefs.data.antialiasing;
    epicTexts.y = FlxG.height / 2 - epicTexts.height / 2;
    changeShit('PSYCH EXTENDED BY');

    logo = new FlxSprite(-125, -100);
    logo.frames = Paths.getSparrowAtlas('logoBumpin');
    logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
    logo.animation.play('bump');
    add(logo);
    logo.antialiasing = ClientPrefs.data.antialiasing;
    logo.alpha = 0;

    gf = new FlxSprite(550, 40);
    gf.frames = Paths.getSparrowAtlas('gfDanceTitle');
    gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
	gf.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
    add(gf);
    gf.antialiasing = ClientPrefs.data.antialiasing;
    gf.alpha = 0;

    titleText = new FlxSprite(150, 576);
    titleText.frames = Paths.getSparrowAtlas('titleEnter');
    titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
	titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
    titleText.animation.addByPrefix('freeze', "FREEZE", 24);
    add(titleText);
    titleText.antialiasing = ClientPrefs.data.antialiasing;
    titleText.animation.play('idle');
    titleText.centerOffsets();
    titleText.updateHitbox();

    titleText.alpha = 0;
    titleText.color = 0xFF33FFFF;
    
    if (!skippedIntro)
        FPSCounterShit();
}

function onCreatePost()
{
    if (!TitleState.initialized)
    {
        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
        FlxG.sound.music.fadeIn(4, 0, 0.7);

        FlxTween.num(255, 32, 60 / Conductor.bpm, {ease: FlxEase.cubeOut}, windowColorTween);
    } else {
        skipIntro();
    }
}

function skipIntro()
{
    skippedIntro = true;
    FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : FlxColor.BLACK, ClientPrefs.data.flashing ? 3 : 1);
    changeShit('');
    gf.alpha = 1;
    logo.alpha = 1;
    titleText.alpha = 1;
}

var curTime:Float = 0;

var changingState:Bool = false;

//fix
/* use global.hx for fix crashes
var ignoreReset = ['editors/chartEditorList', 'geminiState'];
*/

function onUpdate(elapsed:Float)
{
    curTime += elapsed;
    
    //fix
    /* use global.hx for fix crashes
   if ((ignoreReset.contains(ScriptState.targetFileName) ? FlxG.keys.justPressed.F5 : controls.RESET) && CoolVars.developerMode) resetScriptState();
    if (FlxG.sound.music != null)
        Conductor.songPosition = FlxG.sound.music.time;
    FlxG.camera.zoom = fpsLerp(FlxG.camera.zoom, 1, 0.1);
    */
    
    //main code
    var pressedEnter:Bool = controls.ACCEPT;
    
    for (touch in FlxG.touches.list)
	{
		if (touch.justPressed)
		{
			pressedEnter = true;
		}
	}

    if (pressedEnter && !changingState)
    {
        if (skippedIntro)
        {
            titleText.animation.play(ClientPrefs.data.flashing ? 'press' : 'freeze');
            
            changingState = true;

            titleText.color = FlxColor.WHITE;
            titleText.alpha = 1;

            if (ClientPrefs.data.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
            else FlxTween.tween(titleText, {y: FlxG.height}, 60 / Conductor.bpm, {ease: FlxEase.cubeIn});

            FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
            
            if (!TitleState.initialized) TitleState.initialized = true;

            new FlxTimer().start(1.2, function(tmr:FlxTimer)
            {
                CustomSwitchState.switchMenus('MainMenu');
            });
        } else {
            skipIntro();
        }
    }

    if (skippedIntro && !changingState)
    {  
        titleText.alpha = 0.64 + Math.sin(curTime * 2) * 0.36;
    }
}

function changeShit(text:String)
{
    epicTexts.text = text;
    epicTexts.y = FlxG.height / 2 - epicTexts.height / 2;
}

var sickBeats:Float = 0;

var phrases:Array<String> = [
    "PSYCH EXTENDED BY",
    "PSYCH EXTENDED BY",
    "PSYCH EXTENDED BY\nALONEDARK & KRALOYUNCU",
    "",
    "A MODIFIED PSYCH ENGINE",
    "A MODIFIED PSYCH ENGINE\nFOR 0.6.3 PLAYERS",
    "A MODIFIED PSYCH ENGINE\nFOR 0.6.3 PLAYERS",
    "",
    "POWERED BY",
    "POWERED BY\nPSYCH ENGINE",
    "",
    "",
    "FRIDAY",
    "FRIDAY\nNIGHT",
    "FRIDAY\nNIGHT\nFUNKIN'",
    "FRIDAY\nNIGHT\nFUNKIN'\nPSYCH EXTENDED"
];

function onBeatHit()
{
    //fix
    /* use global.hx for fix crashes
    if (ClientPrefs.data.camZooms) FlxG.camera.zoom += 0.01;
    */
    
    //main code
    if(logo != null)
        logo.animation.play('bump', true);

    if (curBeat % 2 == 0)
    {
        gf.animation.play('danceRight');
    }
    if (curBeat % 2 == 1)
    {
        gf.animation.play('danceLeft');
    }

    sickBeats = sickBeats + 1;

    if (!skippedIntro)
    {
        changeShit(phrases[sickBeats]);

        if (sickBeats == 16)
            skipIntro();
    }
}

function windowColorTween(value:Float)
{
    setBorderColor(Math.floor(value), Math.floor(value), Math.floor(value));
}

function FPSCounterShit()
{
    Main.fpsVar.visible = false;
    Main.fpsVarNF.visible = false;
    Main.fpsVarNova.visible = false;

	if (ClientPrefs.data.FPSCounter == 'NovaFlare')
        Main.fpsVarNova.visible = ClientPrefs.data.showFPS;
    else if (ClientPrefs.data.FPSCounter == 'NF')
        Main.fpsVarNF.visible = ClientPrefs.data.showFPS;
    else if (ClientPrefs.data.FPSCounter == 'Psych')
        Main.fpsVar.visible = ClientPrefs.data.showFPS;
}