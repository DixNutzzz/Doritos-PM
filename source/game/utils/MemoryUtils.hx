package game.utils;

import openfl.system.System;
import flixel.FlxG;
import openfl.Assets;

class MemoryUtils {
	public static function clear() {
		Assets.cache.clear();
		FlxG.bitmap.clearCache();

		#if java
		java.vm.Gc.run(true);
		#else
		System.gc();
		#end
	}

	public static function getUsedRAM():Int {
		#if hl
		var _ = 0.0, mem = 0.0;
		@:privateAccess hl.Gc._stats(_, _, mem);
		return Math.floor(mem);
		#elseif java
		return java.vm.Gc.stat().heap;
		#else
		return System.totalMemory;
		#end
	}

	public static function getUsedVRAM():Int {
		return FlxG.stage.context3D?.totalGPUMemory ?? 0;
	}
}
