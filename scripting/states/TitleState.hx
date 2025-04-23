import MainMenuState;
import flixel.text.FlxTextBorderStyle;
import haxe.Json;
import ClientPrefs;
//
import LoadingState;
import PlayState;

var bg:FlxSprite;

function onStartIntroPost()
{
    remove(game.gfDance);
    state.logoBl.x += 300;
    state.logoBl.y += 100;
    bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
	bg.antialiasing = ClientPrefs.data.antialiasing;
	add(bg);
	bg.screenCenter();
}