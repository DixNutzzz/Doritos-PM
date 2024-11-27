package fnf.backend.save;

class ClientPrefs {
	public var antialiasing = true;
	public var downscroll = false;

	public static var data(default, null) = new ClientPrefs();

	public static function save() {}

	public static function load() {}

	public static function reset() {
		data = new ClientPrefs();
	}

	private function new() {}
}
