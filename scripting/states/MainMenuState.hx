import MainMenuState;
import scripting.HScriptStateHandler;

function onCreate()
{
    state.optionShit = [
        'story_mode',
		'freeplay',
		'mods',
		'credits'
	];
	
	state.leftOption = 'options';
	state.rightOption = 'achievements';
}

/* Not Needed Anymore Because addVirtualPad() Fixed
function addHxVirtualPad(?DPad:String = 'NONE', ?Action:String = 'NONE')
{
    state.addHxVirtualPad(HScriptStateHandler.dpadMode.get(DPad), HScriptStateHandler.actionMode.get(Action));
}
*/

function onCreatePost()
{
    addVirtualPad('NONE', 'B_E');
    state._virtualpad.visible = false;
    changeHXButtonPosition('E', FlxG.width - 132, FlxG.height - 375);
    getSpesificVPadButton('B').y = FlxG.height - 375;
}

function changeHXButtonPosition(buttonName:String, X:Float, Y:Float)
{
    getSpesificVPadButton(buttonName).x = X;
    getSpesificVPadButton(buttonName).y = Y;
}

function onUpdate()
{
    var option:String = state.optionShit[MainMenuState.curSelected];
    var item:FlxSprite = state.menuItems.members[MainMenuState.curSelected];
          
    if (controls.ACCEPT || (FlxG.mouse.overlaps(state.menuItems, FlxG.camera) && FlxG.mouse.justPressed))
    {
        FlxFlicker.flicker(HScriptStateHandler._hxvirtualpad, 1, 0.06, false, false); //Lets gooo
        FlxFlicker.flicker(item, 1, 0.06, false, false, function(flick:FlxFlicker)
		{
            switch (option)
            {
                case 'story_mode': CustomSwitchState.switchMenus('StoryMenu');
				case 'freeplay': CustomSwitchState.switchMenus('Freeplay');
				case 'mods': CustomSwitchState.switchMenus('ModsMenu');
				case 'achievements': CustomSwitchState.switchMenus('AchievementsMenu');
				case 'credits': switchToScriptState('CreditsState', true); //CustomSwitchState.switchMenus('Credits');
				case 'options': CustomSwitchState.switchMenus('Options');
            }
        });
    }
    else if (FlxG.keys.anyJustPressed(MainMenuState.debugKeys) || virtualPadJustPressed('E'))
	{
		MainMenuState.instance.selectedSomethin = true;
		FlxG.mouse.visible = false;
		CustomSwitchState.switchMenus('MasterEditor');
	}
}