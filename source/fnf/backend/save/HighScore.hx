package fnf.backend.save;

class HighScore {
	public var songs:Map<String, Int> = [];
	public var levels:Map<String, Int> = [];

	public function setSongScore(song:String, diff = 'normal', score:Int, force = false) {
		var fmtSong = Paths.formatSongPath(song), fmtDiff = Paths.formatSongPath(diff);
		if (force || getSongScore(song, diff) < score) songs['$fmtSong-$fmtDiff'] = score;
	}

	public function getSongScore(song:String, diff = 'normal'):Int {
		var fmtSong = Paths.formatSongPath(song), fmtDiff = Paths.formatSongPath(diff);
		return songs.get('$fmtSong-$fmtDiff') ?? 0;
	}

	public function setLevelScore(level:String, diff = 'normal', score:Int, force = false) {
		var fmtLevel = Paths.formatSongPath(level), fmtDiff = Paths.formatSongPath(diff);
		if (force || getLevelScore(level, diff) < score) levels['$fmtLevel-$fmtDiff'] = score;
	}

	public function getLevelScore(level:String, diff = 'normal'):Int {
		var fmtLevel = Paths.formatSongPath(level), fmtDiff = Paths.formatSongPath(diff);
		return levels.get('$fmtLevel-$fmtDiff') ?? 0;
	}

	public static var data(default, null) = new HighScore();

	public static function save() {}

	public static function load() {}

	public static function reset() {
		data = new HighScore();
	}

	private function new() {}
}
