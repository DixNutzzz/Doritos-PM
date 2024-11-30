package fnf.backend.save;

class ClientPrefs {
	public var antialiasing = true;
	public var downscroll = false;

	public var noteClipByTime = false; // experimental feature
	public var highAccuracyNoteClip = true;

	public static var data(default, null) = new ClientPrefs();

	public static function save() {}

	public static function load() {}

	public static function reset() {
		data = new ClientPrefs();
	}

	private function new() {}
}
