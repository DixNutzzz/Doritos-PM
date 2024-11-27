package fnf.backend;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;
import openfl.utils.AssetType;

class Paths {
	public static inline var AUDIO_EXT = #if html5 'mp3' #else 'ogg' #end;

	public static inline function getPath(file:String, type:AssetType):String {
		return 'assets/$file';
	}

	public static inline function formatSongPath(key:String):String {
		return key.toLowerCase();
	}

	public static function beatmap(song:String, diff = 'normal'):String {
		var fmtSong = formatSongPath(song);
		var fmtDiff = formatSongPath(diff);
		return getPath('songs/$fmtSong/$fmtDiff.beatmap', TEXT);
	}

	public static function chart(song:String, diff = 'normal'):String {
		var fmtSong = formatSongPath(song);
		var fmtDiff = formatSongPath(diff);
		return getPath('songs/$fmtSong/$fmtDiff.json', TEXT);
	}

	public static function inst(song:String, diff = 'normal'):String {
		var fmtSong = formatSongPath(song);
		var fmtDiff = formatSongPath(diff);

		var path = getPath('songs/$fmtSong/song/Inst-$fmtDiff.$AUDIO_EXT', TEXT);
		if (Assets.exists(path)) return path;

		return getPath('songs/$fmtSong/song/Inst.$AUDIO_EXT', TEXT);
	}

	public static function voices(song:String, diff = 'normal', ?suffix:String):String {
		if (suffix == null) suffix = '';

		var fmtSong = formatSongPath(song);
		var fmtDiff = formatSongPath(diff);

		var path = getPath('songs/$fmtSong/song/Voices-$fmtDiff$suffix.$AUDIO_EXT', TEXT);
		if (Assets.exists(path)) return path;

		return getPath('songs/$fmtSong/song/Voices$suffix.$AUDIO_EXT', TEXT);
	}

	public static inline function image(key:String):String {
		return getPath('images/$key.png', IMAGE);
	}

	public static inline function getSparrowAtlas(key:String):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(image(key), getPath('images/$key.xml', TEXT));
	}
}
