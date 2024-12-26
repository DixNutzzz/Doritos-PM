package game.backend;

import flixel.system.debug.log.LogStyle;
import flixel.FlxG;

class Logger {
	public static function init() {
		ANSI.available = true;
		FlxG.log.redirectTraces = true;
		@:privateAccess flixel.FlxG.log._standardTraceFunction = (_, ?_) -> {}

		LogStyle.NORMAL.onLog.add(data -> {
			print(data);
		});

		LogStyle.NOTICE.onLog.add(data -> {
			var str = ANSI.aset([ ANSI.Attribute.Green ]) + '[NOTICE] ${data}' + ANSI.aset([ ANSI.Attribute.DefaultForeground ]);
			print(str);
		});

		LogStyle.WARNING.onLog.add(data -> {
			var str = ANSI.aset([ ANSI.Attribute.Yellow ]) + '[WARNING] ${data}' + ANSI.aset([ ANSI.Attribute.DefaultForeground ]);
			print(str);
		});

		LogStyle.ERROR.onLog.add(data -> {
			var str = ANSI.aset([ ANSI.Attribute.Red ]) + '[ERROR] ${data}' + ANSI.aset([ ANSI.Attribute.DefaultForeground ]);
			print(str);
		});

		LogStyle.CONSOLE.onLog.add(data -> {
			var str = ANSI.aset([ ANSI.Attribute.Blue ]) + '> ${data}' + ANSI.aset([ ANSI.Attribute.DefaultForeground ]);
			print(str);
		});
	}

	private static function print(v:Dynamic) {
		var str = Std.string(v);
		#if js
		if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(str);
		#elseif lua
		untyped __define_feature__("use._hx_print", _hx_print(str));
		#elseif sys
		Sys.println(str);
		#else
		throw new haxe.exceptions.NotImplementedException()
		#end
	}
}
