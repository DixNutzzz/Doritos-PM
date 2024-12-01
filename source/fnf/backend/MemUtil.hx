package fnf.backend;

import openfl.system.System;
import flixel.FlxG;
import openfl.Assets;

class MemUtil {
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

	public static function getAllocatedRAM():Int {
		var result = 0;
		#if cpp
		result = cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_RESERVED);
		#elseif hl
		var _ = 0.0, alloc = 0.0;
		@:privateAccess hl.Gc._stats(alloc, _, _);
		result = Math.floor(alloc);
		#elseif java
		var stats = java.vm.Gc.stats();
		return stats.heap + stats.free;
		#elseif neko
		var stats = neko.vm.Gc.stats();
		return stats.heap + stats.free;
		#end
		return result;
	}

	public static function getUsedVRAM():Int {
		return FlxG.stage.context3D?.totalGPUMemory ?? 0;
	}
}
