import extras.states.MainMenuStateOld;
import flixel.text.FlxTextBorderStyle;
import flixel.effects.FlxFlicker;
import MusicBeatState;

function onCreate()
{
    state.optionShit = [
        'story_mode',
		'freeplay',
		'awards',
		//'mods',
		//'credits',
		'options'
	];
}

function onUpdate()
{
    var option:String = state.optionShit[MainMenuStateOld.curSelected];
    var item:FlxSprite = state.menuItems.members[MainMenuStateOld.curSelected];
          
    if (controls.ACCEPT || (FlxG.mouse.overlaps(state.menuItems, FlxG.camera) && FlxG.mouse.justPressed))
    {
        FlxFlicker.flicker(item, 1, 0.06, false, false, function(flick:FlxFlicker)
		{
            switch (option)
            {
                case 'story_mode': CustomSwitchState.switchMenus('StoryMenu');
				case 'freeplay': CustomSwitchState.switchMenus('Freeplay');
				case 'mods': CustomSwitchState.switchMenus('ModsMenu');
				case 'achievements': CustomSwitchState.switchMenus('AchievementsMenu');
				case 'credits': CustomSwitchState.switchMenus('Credits');
				case 'options': CustomSwitchState.switchMenus('Options');
				case 'awards': CustomSwitchState.switchMenus('AchievementsMenu');
            }
        });
    }
    else if (FlxG.keys.anyJustPressed(MainMenuStateOld.debugKeys) || state._virtualpad.buttonE.justPressed)
	{
		state.selectedSomethin = true;
		FlxG.mouse.visible = false;
		CustomSwitchState.switchMenus('MasterEditor');
	}
}