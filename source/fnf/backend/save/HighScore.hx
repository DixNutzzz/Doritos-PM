package fnf.backend.save;

class HighScore {
	public var songs:Map<String, Tallies> = [];
	public var levels:Map<String, Tallies> = [];

	public function setSongTallies(song:String, diff = 'normal', tallies:Tallies, force = false) {
		var fmtSong = Paths.formatSongPath(song), fmtDiff = Paths.formatSongPath(diff);
		if (force || getSongTallies(song, diff)?.score < tallies.score) songs['$fmtSong-$fmtDiff'] = tallies;
	}

	public function getSongTallies(song:String, diff = 'normal'):Null<Tallies> {
		var fmtSong = Paths.formatSongPath(song), fmtDiff = Paths.formatSongPath(diff);
		return songs.get('$fmtSong-$fmtDiff');
	}

	public function setLevelTallies(level:String, diff = 'normal', tallies:Tallies, force = false) {
		var fmtLevel = Paths.formatSongPath(level), fmtDiff = Paths.formatSongPath(diff);
		if (force || getLevelTallies(level, diff)?.score < tallies.score) levels['$fmtLevel-$fmtDiff'] = tallies;
	}

	public function getLevelTallies(level:String, diff = 'normal'):Null<Tallies> {
		var fmtLevel = Paths.formatSongPath(level), fmtDiff = Paths.formatSongPath(diff);
		return levels.get('$fmtLevel-$fmtDiff');
	}

	public static var data(default, null) = new HighScore();

	public static function save() {}

	public static function load() {}

	public static function reset() {
		data = new HighScore();
	}

	private function new() {}
}

typedef Tallies = {
	var score:Int;
	var notes:Int;
	var misses:Int;
	var ratings:Map<String, Int>;
}

enum abstract Rank(String) from String to String {
	var SFC;
	var GFC;
	var FC;
	var SDCB;
	var CLEAR = 'Clear';

	public static dynamic function fromTallies(tallies:Tallies):Rank {
		var result = CLEAR;

		if (tallies.misses == 0) {
			if (tallies.ratings.get('bad') > 0 || tallies.ratings.get('shit') > 0) result = FC;
			else if (tallies.ratings.get('good') > 0) result = GFC;
			else if (tallies.ratings.get('sick') > 0) result = SFC;
		} else if (tallies.misses < 10)
			result = SDCB;

		return result;
	}
}
