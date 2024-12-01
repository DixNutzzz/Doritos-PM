package fnf.backend;

import flixel.FlxG;
import openfl.Assets;

class MemUtil {
	public static var gcActive(default, null) = true;

	public static inline function setGcState(active: Bool) {
		setGcStateSilent(active);
		gcActive = active;
	}

	public static inline function enableGc() setGcState(true);
	public static inline function disableGc() setGcState(false);

	public static function gc() {
		setGcStateSilent(true);
		#if cpp
		cpp.vm.Gc.run(true);
		#elseif hl
		hl.Gc.major();
		#elseif java
		java.vm.Gc.run(true);
		#elseif neko
		neko.vm.Gc.run(true);
		#end
		setGcStateSilent(gcActive);
	}

	public static function clear(gc = false) {
		Assets.cache.clear();
		FlxG.bitmap.clearCache();
		if (gc) MemUtil.gc();
	}

	public static function getUsedMemory(): Int {
		setGcStateSilent(true);
		var result = 0;
		#if cpp
		result = cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_USAGE);
		#elseif hl
		var _ = 0.0, mem = 0.0;
		@:privateAccess hl.Gc._stats(_, _, mem);
		result = Math.floor(mem);
		#elseif java
		result = java.vm.Gc.stat().heap;
		#elseif neko
		result = neko.vm.Gc.stats().heap;
		#end
		setGcStateSilent(gcActive);
		return result;
	}

	public static function getAllocatedMemory(): Int {
		setGcStateSilent(true);
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
		setGcStateSilent(gcActive);
		return result;
	}

	private static function setGcStateSilent(active: Bool) {
		#if cpp
		cpp.vm.Gc.enable(active);
		#elseif hl
		hl.Gc.enable(active);
		#end
	}
}
