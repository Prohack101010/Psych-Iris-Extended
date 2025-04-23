import flixel.text.FlxText;
import flixel.text.FlxTextFormat;
import flixel.text.FlxTextFormatMarkerPair;
import flixel.text.FlxTextBorderStyle;
import extras.CustomSwitchState;
import ClientPrefs;
import options.OptionsState;
import PlayState;
import flixel.animation.FlxAnimationController;
import MusicBeatState;

var bg:FlxSprite;
var magentaBg:FlxSprite;

var options:Array<String> = ['story_mode', 'freeplay', 'mods', 'awards', 'credits', 'options'];
var images:Array<FlxSprite> = [];

var selectedMenu:String;

var version:FlxText;

var selInt:Int = 0;

function onCreate()
{
    if (existsGlobalVar('mainMenuStateSelInt'))
    {
        selInt = getGlobalVar('mainMenuStateSelInt');
    }

    bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
    add(bg);
    bg.antialiasing = ClientPrefs.data.antialiasing;
    bg.scrollFactor.set(0, 0.25 * 5 / options.length);
    bg.scale.set(1.25, 1.25);
    bg.screenCenter('x');

    magentaBg = new FlxSprite().loadGraphic(Paths.image('menuBGMagenta'));
    add(magentaBg);
    magentaBg.antialiasing = ClientPrefs.data.antialiasing;
    magentaBg.scrollFactor.set(0, 0.25 * 5 / options.length);
    magentaBg.scale.set(1.25, 1.25);
    magentaBg.screenCenter('x');
    magentaBg.visible = false;

    for (i in options)
    {
        var img = new FlxSprite();
        img.frames = Paths.getSparrowAtlas('mainmenu/menu_' + i);
        img.animation.addByPrefix('basic', i + ' basic', 24, true);
        img.animation.addByPrefix('white', i + ' white', 24, true);
        img.animation.play('basic', true);
        add(img);
        img.antialiasing = ClientPrefs.data.antialiasing;
        img.scrollFactor.set(0, (options.length - 4) - 0.5);
        images.push(img);
    }

    Type.resolveEnum('flixel.text.FlxTextBorderStyle').OUTLINE;
		
    version = new FlxText(10, 0, 0, '');
    version.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, 'left');
    add(version);
    version.borderStyle = FlxTextBorderStyle.OUTLINE;
    version.borderSize = 1;
    version.borderColor = FlxColor.BLACK;
    version.antialiasing = ClientPrefs.data.antialiasing;
    version.applyMarkup(
        "Psych Extended v1.0.1\nPsych Engine v0.6.4b\nFriday Night Funkin' v0.2.8",
        [
            new FlxTextFormatMarkerPair(new FlxTextFormat(CoolUtil.colorFromString('00FFFF')), '*'),
            new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.fromRGB(255, 125, 255)), '`')
        ]
    );
    version.scrollFactor.set(0, 0);
    version.y = FlxG.height - version.height - 10;

    changeShit();
    
    addVirtualPad('UP_DOWN', 'A_B_E');
}

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    if (canSelect)
    {
        if (controls.BACK)
        {
            canSelect = false;

            FlxG.sound.play(Paths.sound('cancelMenu'));
    
            new FlxTimer().start(0.25, function(tmr:FlxTimer)
            {
                CustomSwitchState.switchMenus('Title');
            });

            setGlobalVar('mainMenuStateSelInt', selInt);
        }

        if (options.length > 1)
        {
            if (controls.UI_UP_P || controls.UI_DOWN_P || FlxG.mouse.wheel != 0)
            {
                if (controls.UI_UP_P || FlxG.mouse.wheel > 0)
                {
                    if (selInt > 0)
                    {
                        selInt -= 1;
                    } else if (selInt == 0) {
                        selInt = options.length - 1;
                    }
        
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                } else if (controls.UI_DOWN_P ||  FlxG.mouse.wheel < 0) {
                    if (selInt < options.length - 1)
                    {
                        selInt += 1;
                    } else if (selInt == options.length - 1) {
                        selInt = 0;
                    }
        
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                }
        
                changeShit();
            }
        }

        if (controls.ACCEPT)
        {
            if (ClientPrefs.data.flashing) FlxFlicker.flicker(magentaBg, 1.1, 0.15, false);

            canSelect = false;

            for (i in 0...images.length)
            {
                if (i == selInt)
                {
                    if (ClientPrefs.data.flashing) FlxFlicker.flicker(images[i], 0, 0.05);
                } else {
                    FlxTween.tween(images[i], {alpha: 0}, 60 / Conductor.bpm, {ease: FlxEase.cubeIn});
                }
            }

            setGlobalVar('mainMenuStateSelInt', selInt);

            FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
        
            new FlxTimer().start(1, function(tmr:FlxTimer)
            {
                switch (selectedMenu)
                {
                    case 'story_mode':
                        CustomSwitchState.switchMenus('StoryMenu');
                    case 'freeplay':
                        CustomSwitchState.switchMenus('Freeplay');
					case 'mods':
						CustomSwitchState.switchMenus('ModsMenu');
					case 'awards':
						CustomSwitchState.switchMenus('AchievementsMenu');
                    case 'credits':
                        CustomSwitchState.switchMenus('Credits');
                    case 'options':
                        CustomSwitchState.switchMenus('Options');
                }
            });
        }
        
        var debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
        if (FlxG.keys.anyJustPressed(debugKeys) || virtualPadJustPressed("E")) CustomSwitchState.switchMenus('MasterEditor');
    }

    FlxG.camera.scroll.y = fpsLerp(FlxG.camera.scroll.y, (selInt + (options.length - 1) / 2) * 25, 0.1);
}

function changeShit()
{
    for (i in 0...options.length)
    {
        if (i == selInt)
        {
            images[i].animation.play('white');
            selectedMenu = options[i];
        } else {
            images[i].animation.play('basic');
        }
    
        images[i].centerOffsets();
        images[i].x = FlxG.width / 2 - images[i].width / 2;
        images[i].y = (FlxG.height / (images.length + -1) * (i + 1) - images[i].height / 2) + 50;
    }
}