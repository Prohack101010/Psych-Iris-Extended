import haxe.ds.StringMap;
import flixel.text.FlxText;
import flixel.text.FlxTextFormat;
import flixel.text.FlxTextFormatMarkerPair;
import flixel.group.FlxTypedGroup;
import MenuCharacter;
import tjson.TJSON as Json;
import backend.Mods;
import extras.CustomSwitchState;

import Difficulty;
import Highscore;
import LoadingState;
import PlayState;
import WeekData;
import Song;

var weeksSelInt:Int = existsGlobalVar('storyMenuStateSongsSelInt') ? getGlobalVar('storyMenuStateSongsSelInt') : 0;
var difficultiesSelInt:Int = existsGlobalVar('storyMenuStateDifficultiesSelInt') ? getGlobalVar('storyMenuStateDifficultiesSelInt') : 0;

var characters:FlxTypedGroup<MenuCharacter>;
var bg:FlxSprite;
var difficultyImage:FlxSprite;
var uiLeft:FlxSprite;
var uiRight:FlxSprite;
var songsText:FlxText;
var weekPhrase:FlxText;
var weekScore:FlxText;

function onCreate()
{
    WeekData.reloadWeekFiles(true);

    var foldersToCheck = [];

    if (FileSystem.exists(Paths.getPreloadPath('weeks')) && FileSystem.isDirectory(Paths.getPreloadPath('weeks'))) foldersToCheck.push(Paths.getPreloadPath('weeks'));
    for (folder in Mods.getModDirectories())
        if (FileSystem.exists(Paths.mods(folder + '/weeks')) && FileSystem.isDirectory(Paths.mods(folder + '/weeks'))) foldersToCheck.push(Paths.mods(folder + '/weeks'));

    var weeks = [];

    for (folder in foldersToCheck)
    {
        var files = FileSystem.readDirectory(folder).filter(function(file) return StringTools.endsWith(file, '.json'));

        for (file in files)
        {
            var replaced = false;

            for (i in 0...weeks.length)
            {
                if (weeks[i][1] != null && weeks[i][1] == file) 
                {
                    weeks[i][0] = folder;

                    replaced = true;
                }
            }

            if (!replaced) weeks.push([folder, file]);
        }
    }

    for (week in weeks)
    {
        var jsonData = Json.parse(File.getContent(week[0] + '/' + week[1]));

        var jsonDiff:Array = Reflect.hasField(jsonData, 'difficulties') && jsonData.difficulties != '' ? jsonData.difficulties.split(' ').join('').split(',') : null;
        var songs:Array = [];

        for (song in jsonData.songs) songs.push(song[0]);

        if (!week.hideStoryMode) addWeek(week[1].substr(0, week[1].length - 5), songs, jsonData.weekCharacters, jsonData.weekBackground, jsonData.storyName, jsonDiff == null ? ['Easy', 'Normal', 'Hard'] : jsonDiff);
    }
    
    uiLeft = new FlxSprite(0, 480);
    uiLeft.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
    uiLeft.animation.addByPrefix('push', "arrow push left", 24, false);
    uiLeft.animation.addByPrefix('left', "arrow left", 24, false);
    uiLeft.animation.play('left');
    add(uiLeft);
    uiLeft.antialiasing = ClientPrefs.data.antialiasing;
    uiLeft.scrollFactor.set(0, 0);

    uiRight = new FlxSprite(0, 480);
    uiRight.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
    uiRight.animation.addByPrefix('push', "arrow push right", 24, false);
    uiRight.animation.addByPrefix('right', "arrow right", 24, false);
    uiRight.animation.play('right');
    add(uiRight);
    uiRight.antialiasing = ClientPrefs.data.antialiasing;
    uiRight.x = FlxG.width - uiRight.width - 5;
    uiRight.scrollFactor.set(0, 0);

    difficultyImage = new FlxSprite();
    add(difficultyImage);
    difficultyImage.antialiasing = ClientPrefs.data.antialiasing;
    difficultyImage.scrollFactor.set(0, 0);

    songsText = new FlxText(0, 480, 0, 'TRACKS');
    songsText.setFormat(Paths.font('fullPhantomMuff.ttf'), 45, FlxColor.PINK, 'center');
    add(songsText);
    songsText.scrollFactor.set(0, 0);
    songsText.antialiasing = ClientPrefs.data.antialiasing;
    songsText.x = FlxG.width / 5 - songsText.width / 2 - 50;
    
    var phraseBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 50, FlxColor.BLACK);
    add(phraseBG);
    phraseBG.scrollFactor.set(0, 0);

    weekPhrase = new FlxText(0, 10, 0, '');
    weekPhrase.setFormat(Paths.font('vcr.ttf'), 35);
    add(weekPhrase);
    weekPhrase.scrollFactor.set(0, 0);
    weekPhrase.antialiasing = ClientPrefs.data.antialiasing;
    weekPhrase.x = FlxG.width - weekPhrase.width - 10;

    weekScore = new FlxText(10, 10, 0, '');
    weekScore.setFormat(Paths.font('vcr.ttf'), 35);
    add(weekScore);
    weekScore.scrollFactor.set(0, 0);
    weekScore.antialiasing = ClientPrefs.data.antialiasing;

    bg = new FlxSprite(0, 50);
    add(bg);
    bg.antialiasing = ClientPrefs.data.antialiasing;
    bg.scrollFactor.set(0, 0);

    characters = new FlxTypedGroup<MenuCharacter>();
    add(characters);

    for (i in 1...4)
    {
        var character:MenuCharacter = new MenuCharacter(FlxG.width * 0.25 * i - 150, '');
        characters.add(character);
        character.antialiasing = ClientPrefs.data.antialiasing;
        character.scrollFactor.set(0, 0);
        character.y += 65;
    }
    
    var tipBG = new FlxSprite().makeGraphic(FlxG.width, 30, FlxColor.BLACK);
    add(tipBG);
    tipBG.alpha = 0.5;
    tipBG.y = FlxG.height - tipBG.height;

    var tipText = new FlxText(0, 10, 1240, 'Press CONTROL to Open the Gameplay Changers Menu');
    tipText.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, 'right');
    add(tipText);
    tipText.antialiasing = ClientPrefs.data.antialiasing;
    tipText.y = tipBG.y + tipBG.height / 2 - tipText.height / 2;
    
    changeDifficultyShit();
    changeWeeksShit();
    
    addVirtualPad('FULL', 'A_B_X_Y');
    addVirtualPadCamera();
}

var weeks:Array<StringMap<Dynamic>> = [];
var difficulties:Array<String> = [];

function addWeek(weekName:String, songs:Array, characters:Array, stage:String, storyName:String, difficulties:Array)
{
    var weekData:StringMap = new StringMap();

    var image:FlxSprite = new FlxSprite(0, 490 + (weeks.length - weeksSelInt) * 105).loadGraphic(Paths.image('storymenu/' + weekName));
    image.alpha = 0.5;
    image.scale.set(0.9, 0.9);
    image.updateHitbox();
    image.x = FlxG.width / 2 - image.width / 2 - 20;
    image.antialiasing = ClientPrefs.data.antialiasing;
    add(image);

    weekData.set('name', weekName);
    weekData.set('image', image);
    weekData.set('songs', songs);
    weekData.set('characters', characters);
    weekData.set('stage', stage);
    weekData.set('storyName', storyName);
    weekData.set('difficulties', difficulties);

    weeks.push(weekData);
}

function changeWeeksShit()
{
    for (week in weeks)
    {
        if (weeks.indexOf(week) == weeksSelInt)
        {
            if (week.get('image').alpha != 1) week.get('image').alpha = 1;

            songsText.text = 'TRACKS\n' + week.get('songs').join('\n');
            songsText.x = FlxG.width / 5 - songsText.width / 2 - 50;

            weekPhrase.text = week.get('storyName').toUpperCase();
            weekPhrase.x = FlxG.width - weekPhrase.width - 10;

            bg.loadGraphic(Paths.image('menubackgrounds/menu_' + week.get('stage')));

            for (i in 0...3) characters.members[i].changeCharacter(week.get('characters')[i]);
        } else {
            if (week.get('image').alpha != 0.5) week.get('image').alpha = 0.5;
        }

        FlxTween.cancelTweensOf(week.get('image'));
        FlxTween.tween(week.get('image'), {y: 490 + 105 * (weeks.indexOf(week) - weeksSelInt)}, 30 / Conductor.bpm, {ease: FlxEase.cubeOut});
    }

    FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
}

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    if (canSelect)
    {
        if (weeks.length > 1)
        {
            if (controls.UI_UP_P || controls.UI_DOWN_P || FlxG.mouse.wheel != 0)
            {
                if (controls.UI_UP_P || FlxG.mouse.wheel > 0)
                {
                    if (weeksSelInt > 0)
                    {
                        weeksSelInt -= 1;
                    } else if (weeksSelInt == 0) {
                        weeksSelInt = weeks.length - 1;
                    }
            
                } else if (controls.UI_DOWN_P || FlxG.mouse.wheel < 0) {
                    if (weeksSelInt < (weeks.length - 1))
                    {
                        weeksSelInt += 1;
                    } else if (weeksSelInt == weeks.length - 1) {
                        weeksSelInt = 0;
                    }
                }

                changeWeeksShit();
                changeDifficultyShit();
            }
        }

        if (difficulties.length > 1)
        {
            if (controls.UI_LEFT_P)
            {
                if (difficultiesSelInt > 0)
                {
                    difficultiesSelInt -= 1;
                } else if (difficultiesSelInt == 0) {
                    difficultiesSelInt = difficulties.length - 1;
                }

                uiLeft.animation.play('push');
                uiLeft.centerOffsets();
            } else if (controls.UI_LEFT_R) {
                uiLeft.animation.play('left');
                uiLeft.centerOffsets();
            }
    
            if (controls.UI_RIGHT_P)
            {
                if (difficultiesSelInt < (difficulties.length - 1))
                {
                    difficultiesSelInt += 1;
                } else if (difficultiesSelInt == difficulties.length - 1) {
                    difficultiesSelInt = 0;
                }
    
                uiRight.animation.play('push');
                uiRight.centerOffsets();
            } else if (controls.UI_RIGHT_R) {
                uiRight.animation.play('right');
                uiRight.centerOffsets();
            }    

            if (controls.UI_LEFT_P || controls.UI_RIGHT_P) changeDifficultyShit();
        }
        
        if (controls.BACK)
        {
            setGlobalVar('storyMenuStateSongsSelInt', weeksSelInt);
            setGlobalVar('storyMenuStateDifficultiesSelInt', difficultiesSelInt);

            CustomSwitchState.switchMenus('MainMenu');

            canSelect = false;
        }

        if (controls.ACCEPT)
        {
            setGlobalVar('storyMenuStateSongsSelInt', weeksSelInt);
            setGlobalVar('storyMenuStateDifficultiesSelInt', difficultiesSelInt);
            
            for (week in weeks)
            {
                if (weeks.indexOf(week) == weeksSelInt)
                {
                    if (ClientPrefs.data.flashing) FlxFlicker.flicker(week.get('image'), 0, 0.05);

                    FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

                    PlayState.storyPlaylist = week.get('songs');
                    PlayState.isStoryMode = true;

                    Difficulty.loadFromWeek();
        
                    var diffic = Difficulty.getFilePath(difficultiesSelInt);
                    if (diffic == null) diffic = '';
        
                    PlayState.storyDifficulty = difficultiesSelInt;
        
                    PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
                    PlayState.campaignScore = 0;
                    PlayState.campaignMisses = 0;
                    
                    for (char in characters.members)
                    {
                        if (char.character != '' && char.hasConfirmAnimation)
                        {
                            char.animation.play('confirm');
                        }
                    }

                    new FlxTimer().start(1, function(tmr:FlxTimer)
                    {
                        LoadingState.loadAndSwitchState(new PlayState(), true);
                    });
                } else {
                    FlxTween.tween(week.get('image'), {alpha: 0}, 0.5, {ease: FlxEase.cubeIn});
                }
            }

            canSelect = false;
        }

        if (FlxG.keys.justPressed.CONTROL || ScriptState._hxvirtualpad.buttonX.justPressed) openSubState('GameplayChangersSubstate', []);
    }
}

function changeDifficultyShit()
{
    for (week in weeks)
    {
        if (weeks.indexOf(week) == weeksSelInt)
        {
            if (difficulties.length != week.get('difficulties').length) difficultiesSelInt = 0;

            difficulties = week.get('difficulties');

            weekScore.text = 'SCORE: ' + Highscore.getWeekScore(week.get('name'), difficultiesSelInt);
        }
    }

    if (difficulties.length > 1) uiLeft.alpha = uiRight.alpha = 1;
    else uiLeft.alpha = uiRight.alpha = 0;

    difficultyImage.loadGraphic(Paths.image('menudifficulties/' + difficulties[difficultiesSelInt].toLowerCase()));
    difficultyImage.x = FlxG.width / 5 * 4 - difficultyImage.width / 2;
    difficultyImage.y = uiRight.y + uiRight.height / 2 - difficultyImage.height / 2;
    
    uiLeft.x = difficultyImage.x - uiLeft.width - 5;
    
    uiRight.x = difficultyImage.x + difficultyImage.width + 5;
}