package game.data.song.migration;

class BaseSongMigrator {
	public final function new() {}

	public function match(input:Dynamic):Bool return false;
	public function migrate(input:Dynamic):Dynamic throw new haxe.exceptions.NotImplementedException();

	private function matchVar(value:Dynamic, type:Dynamic):Bool {
		return value != null && Std.isOfType(value, type);
	}

	private function matchOptVar(value:Dynamic, type:Dynamic):Bool {
		return value == null || Std.isOfType(value, type);
	}
}
