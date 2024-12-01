package fnf.backend;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;
import openfl.utils.AssetType;

enum abstract AtlasType(Int) from Int to Int {
	var SPARROW;
	var PACKER;
	var ANIMATE;
	var ASEPRITE;
}

class Paths {
	public static inline var AUDIO_EXT = #if html5 'mp3' #else 'ogg' #end;

	public static inline function getPath(file:String, type:AssetType):String {
		return 'assets/${file}';
	}

	public static inline function formatSongPath(key:String):String {
		return key.toLowerCase();
	}

	public static inline function data(file:String):String {
		return getPath('data/${file}', TEXT);
	}

	public static inline function image(key:String):String {
		return getPath('images/${key}.png', IMAGE);
	}

	public static inline function getSparrowAtlas(key:String):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(image(key), getPath('images/${key}.xml', TEXT));
	}

	public static inline function inst(song:String, diff = 'normal'):String {
		var fmtSong = formatSongPath(song), fmtDiff = formatSongPath(diff);

		var path = getPath('songs/${fmtSong}/Inst-${fmtDiff}.${AUDIO_EXT}', SOUND);
		if (Assets.exists(path, SOUND))
			return path;

		return getPath('songs/${fmtSong}/Inst.${AUDIO_EXT}', SOUND);
	}

	public static inline function vocals(song:String, diff = 'normal', ?suffix:String):String {
		if (suffix == null)
			suffix = '';
		var fmtSong = formatSongPath(song), fmtDiff = formatSongPath(diff);

		var path = getPath('songs/${fmtSong}/Voices-${fmtDiff}${suffix}.${AUDIO_EXT}', SOUND);
		if (Assets.exists(path, SOUND))
			return path;

		return getPath('songs/${fmtSong}/Voices${suffix}.${AUDIO_EXT}', SOUND);
	}
}
