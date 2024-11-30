package fnf.scripting.scripts;

import openfl.Assets;
import rulescript.RuleScriptInterp;
import rulescript.HxParser;

class HScript extends Script {
	private var parser:HxParser;
	private var interp:RuleScriptInterp;

	public function new(path:String) {
		parser = new HxParser();
		parser.allowAll();
		interp = new RuleScriptInterp();

		var content = Assets.getText(path);
		var expr = parser.parse(content);
		interp.execute(expr);
	}

	public function get(name:String):Dynamic {
		return interp.variables.get(name);
	}

	public function set(name:String, value:Dynamic):Dynamic {
		interp.variables[name] = value;
		return value;
	}

	public function call(name:String, args:Array<Dynamic>):Dynamic {
		var fn = interp.variables.get(name);
		var cargs = args.copy();
		while (cargs.length >= 0) {
			try return Reflect.callMethod({}, fn, cargs)
				catch(e) cargs.pop();
		}
		return null;
	}
}
