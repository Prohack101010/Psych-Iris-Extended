function onCreate() {
    state.options = [
		'Week Editor',
		'Menu Character Editor',
		'Dialogue Editor',
		'Dialogue Portrait Editor',
		'Character Editor',
		'Chart Editor',
		'Stage Editor'
	];
}

function onUpdate() {
    if (controls.ACCEPT)
	{
		switch(state.options[state.curSelected]) {
			case 'Stage Editor':
				//your Stage Editor
		}
		FlxG.sound.music.volume = 0;
	}
}