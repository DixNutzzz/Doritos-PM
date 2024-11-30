package fnf.backend;

class GcUtil {
	public static var isActive(default, null) = true;

	public static inline function setState(active: Bool) {
		setStateSilent(active);
		isActive = active;
	}

	public static inline function enable() setState(true);
	public static inline function disable() setState(false);

	public static function force() {
		setStateSilent(true);
		#if cpp
		cpp.vm.Gc.run(true);
		#elseif eval
		eval.vm.Gc.major();
		#elseif hl
		hl.Gc.major();
		#elseif java
		java.vm.Gc.run(true);
		#elseif neko
		neko.vm.Gc.run(true);
		#end
		setStateSilent(isActive);
	}

	public static function getUsedMemory(): Int {
		setStateSilent(true);
		var result = 0;
		#if cpp
		result = cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_USAGE);
		#elseif eval
		var stat = eval.vm.Gc.stat();
		result = stat.heap_words + stat.stack_size * 2;
		#elseif hl
		var _ = 0.0, mem = 0.0;
		@:privateAccess hl.Gc._stats(_, _, mem);
		result = Math.floor(mem);
		#elseif java
		result = java.vm.Gc.stat().heap;
		#elseif neko
		result = neko.vm.Gc.stats().heap;
		#end
		setStateSilent(isActive);
		return result;
	}

	public static function getAllocatedMemory(): Int {
		setStateSilent(true);
		var result = 0;
		#if cpp
		result = cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_RESERVED);
		#elseif eval
		var stat = eval.vm.Gc.stat();
		result = stat.heap_words + stat.stack_size + stat.free_words * 2;
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
		setStateSilent(isActive);
		return result;
	}

	private static function setStateSilent(active: Bool) {
		#if cpp
		cpp.vm.Gc.enable(active);
		#elseif hl
		hl.Gc.enable(active);
		#end
	}
}
