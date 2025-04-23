package scripting;

/*
I'm recommend to use `(newScript = new HScript(null, file)).setParent(this);` instead of CustomInterp because It's much better and supports Substates without any issue
*/

/*
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
USE `(newScript = new HScript(null, file)).setParent(this);` INSTEAD
*/

//Original PsychEngine Custom Interp
class CustomInterp extends crowplexus.hscript.Interp
{
	public var parentInstance(default, set):Dynamic = [];
	private var _instanceFields:Array<String>;
	function set_parentInstance(inst:Dynamic):Dynamic
	{
		parentInstance = inst;
		if(parentInstance == null)
		{
			_instanceFields = [];
			return inst;
		}
		_instanceFields = Type.getInstanceFields(Type.getClass(inst));
		return inst;
	}

	public function new()
	{
		super();
	}

	override function fcall(o:Dynamic, funcToRun:String, args:Array<Dynamic>):Dynamic {
		for (_using in usings) {
			var v = _using.call(o, funcToRun, args);
			if (v != null)
				return v;
		}

		var f = get(o, funcToRun);

		if (f == null) {
			Iris.error('Tried to call null function $funcToRun', posInfos());
			return null;
		}

		return Reflect.callMethod(o, f, args);
	}

	override function resolve(id: String): Dynamic {
		if (locals.exists(id)) {
			var l = locals.get(id);
			return l.r;
		}

		if (variables.exists(id)) {
			var v = variables.get(id);
			return v;
		}

		if (imports.exists(id)) {
			var v = imports.get(id);
			return v;
		}

		if(parentInstance != null && _instanceFields.contains(id)) {
			var v = Reflect.getProperty(parentInstance, id);
			return v;
		}

		error(EUnknownVariable(id));

		return null;
	}
}