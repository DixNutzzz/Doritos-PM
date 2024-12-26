package game.backend;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;

class Paths {
	public static inline function formatSongPath(s:String):String {
		return s.toLowerCase();
	}

	public static function file(key:String, type:AssetType):String {
		return 'assets/${key}';
	}

	public static inline function image(key:String):String {
		return file('images/${key}.png', IMAGE);
	}

	public static inline function getSparrowAtlas(key:String):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(image(key), file('images/${key}.xml', TEXT));
	}

	public static inline function inst(song:String, ?diff = 'normal'):String {
		var fmtSong = formatSongPath(song);
		var fmtDiff = formatSongPath(diff);

		var path = file('songs/${fmtSong}/song/Inst-${fmtDiff}', SOUND);
		if (FlxG.assets.exists(path, SOUND)) return path;

		return file('songs/${fmtSong}/song/Inst', SOUND);
	}

	public static inline function vocals(song:String, ?diff = 'normal', ?suffix:String):String {
		if (suffix == null) suffix = '';

		var fmtSong = formatSongPath(song);
		var fmtDiff = formatSongPath(diff);

		var path = file('songs/${fmtSong}/song/Voices-${fmtDiff}${suffix}', SOUND);
		if (FlxG.assets.exists(path, SOUND)) return path;

		return file('songs/${fmtSong}/song/Voices${suffix}', SOUND);
	}

	public static inline function font(key:String):String {
		return file('fonts/${key}', FONT);
	}

	public static inline function sound(key:String):String {
		return file('sounds/${key}', SOUND);
	}
}
