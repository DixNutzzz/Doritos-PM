package fnf.backend.beatmap.migration;

class BaseBeatmapMigrator<T> {
	public function new() {}

	public function match(data:Dynamic):Bool return false;
	public function migrate(input:T):BeatmapData return null;

	private inline function isVarMatch(value:Dynamic, type:Dynamic):Bool {
		return value != null && Std.isOfType(value, type);
	}

	private inline function isOptionalVarMatch(value:Dynamic, type:Dynamic):Bool {
		return value == null || Std.isOfType(value, type);
	}
}
