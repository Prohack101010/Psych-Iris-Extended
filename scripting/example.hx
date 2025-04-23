class Test extends HScriptStateHandler
{
    override function create() {
        var className = Type.getClassName(Type.getClass(this));
	    var classString:String = '${className}' + '.hx';
	    if (classString.startsWith('extras.states.')) classString = classString.replace('extras.states.', '');
	    startHScriptsNamed(classString);
    	startHScriptsNamed('global.hx');
    	
        //your code
        super.create();
        callOnScripts('onCreatePost');
    }
    
    override function closeSubState() {
	    callOnScripts('onCloseSubState');
		//your code
		super.closeSubState();
		callOnScripts('onCloseSubStatePost');
	}
	
	override function update(elapsed:Float) {
	    callOnScripts('onUpdate', [elapsed]);
	    //your code
	    super.update();
	    callOnScripts('onUpdatePost', [elapsed]);
	}
}