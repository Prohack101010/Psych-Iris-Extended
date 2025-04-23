import MainMenuState;
import MusicBeatState;
import flixel.text.FlxTextBorderStyle;
import scripting.HScriptStateHandler;
import editors.ChartingState;
import PlayState;
import WeekData;
import Highscore;
import LoadingState;
import Paths;
import haxe.Json;

var lightOn:String = 'Light On';
var lightOff:String = 'Light Off';

function onCreatePost() {
    changeButtonPosition('X', FlxG.width - 44 * 3, FlxG.height - 125 * 3 -25);
    changeButtonPosition('Left', FlxG.width - 128 * 3, FlxG.height - 125 * 3 -25);
    changeButtonPosition('Right', FlxG.width - 86 * 3, FlxG.height - 125 * 3 -25);
    changeButtonPosition('Up', 0, FlxG.height - 85 * 3 -25);
    changeButtonPosition('Down', 0, FlxG.height - 45 * 3 -25);
    HScriptStateHandler.instance.addHxVirtualPad(HScriptStateHandler.dpadMode.get('NONE'), HScriptStateHandler.actionMode.get('A_B_E'));
    //Extras
    changeHXButtonPosition('A', FlxG.width - 10000, FlxG.height - 125 * 3 -25);
    changeHXButtonPosition('B', FlxG.width - 10000, FlxG.height - 125 * 3 -25);
    changeHXButtonPosition('E', FlxG.width - 128 * 3, FlxG.height - 85 * 3 -25);
    game._virtualpad.y = -25;
}

function changeButtonPosition(buttonName:String, X:Float, Y:Float)
{
    buttonName = 'button' + buttonName;
    var Button = Reflect.getProperty(game._virtualpad, buttonName);
    Button.x = X;
    Button.y = Y;
}

function changeHXButtonPosition(buttonName:String, X:Float, Y:Float)
{
    buttonName = 'button' + buttonName;
    var Button = Reflect.getProperty(HScriptStateHandler._hxvirtualpad, buttonName);
    Button.x = X;
    Button.y = Y;
}

//function onUpdate() game.bg.color = -7179779;

function onUpdate() {
    //if (game._virtualpad.buttonC.justPressed) HScriptStateHandler._hxvirtualpad.visible = false;
    if (game._virtualpad.buttonC.justPressed) FlxTween.tween(game._virtualpad, {alpha: 0}, 1, {ease: FlxEase.quadOut});
    if (game._virtualpad.buttonC.justPressed) FlxTween.tween(HScriptStateHandler._hxvirtualpad, {alpha: 0}, 1, {ease: FlxEase.quadOut});
}

function onCloseSubState() HScriptStateHandler._hxvirtualpad.visible = true;

function onCloseSubStatePost() {
    changeButtonPosition('X', FlxG.width - 44 * 3, FlxG.height - 125 * 3);
    changeButtonPosition('Left', FlxG.width - 128 * 3, FlxG.height - 125 * 3);
    changeButtonPosition('Right', FlxG.width - 86 * 3, FlxG.height - 125 * 3);
    changeButtonPosition('Up', 0, FlxG.height - 85 * 3);
    changeButtonPosition('Down', 0, FlxG.height - 45 * 3);
    game._virtualpad.y = -25;
    FlxTween.tween(game._virtualpad, {alpha: ClientPrefs.data.VirtualPadAlpha}, 1, {ease: FlxEase.quadOut});
    FlxTween.tween(HScriptStateHandler._hxvirtualpad, {alpha: ClientPrefs.data.VirtualPadAlpha}, 1, {ease: FlxEase.quadOut});
}