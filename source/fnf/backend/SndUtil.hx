package fnf.backend;

import openfl.media.SoundChannel;
import flixel.sound.FlxSound;
import haxe.extern.EitherType;

typedef Snd = EitherType<FlxSound, SoundChannel>;

class SndUtil {
	public static function getAccuratePos(soundOrChannel:Snd):Null<Float> {
		if (soundOrChannel is FlxSound) return @:privateAccess (soundOrChannel : FlxSound)?._channel?.position;
		else if (soundOrChannel is SoundChannel) return (soundOrChannel : SoundChannel)?.position;
		return null;
	}

	public static function setPos(soundOrChannel:Snd, pos:Float) {
		if (soundOrChannel is FlxSound) (soundOrChannel : FlxSound).time = pos;
		else if (soundOrChannel is SoundChannel) (soundOrChannel : SoundChannel).position = pos;
	}

	public static function sync(main:Snd, subs:Array<Snd>, force = false) {
		var mainPos = getAccuratePos(main);
		var mainPitch = getPitch(main);
		for (sub in subs) {
			if (getPitch(sub) != mainPitch || Math.abs(getAccuratePos(sub) - mainPos) > 20) {
				setPos(sub, mainPos);
				setPitch(sub, mainPitch);
			}
		}
	}

	public static function getPitch(soundOrChannel:Snd):Float {
		if (soundOrChannel is FlxSound) return (soundOrChannel : FlxSound).pitch;
		else if (soundOrChannel is SoundChannel) @:privateAccess {
			var channel:SoundChannel = soundOrChannel;
			#if (openfl < "9.3.2")
			if (channel.__source != null) return channel.__source.pitch;
			#else
			if (channel.__audioSource != null) return channel.__audioSource.pitch;
			#end
		}
		return 1;
	}

	public static function setPitch(soundOrChannel:Snd, pitch = 1.0) {
		if (soundOrChannel is FlxSound) (soundOrChannel : FlxSound).pitch = pitch;
		else if (soundOrChannel is SoundChannel) @:privateAccess {
			var channel:SoundChannel = soundOrChannel;
			#if (openfl < "9.3.2")
			if (channel.__source != null) channel.__source.pitch = pitch;
			#else
			if (channel.__audioSource != null) channel.__audioSource.pitch = pitch;
			#end
		}
	}
}
