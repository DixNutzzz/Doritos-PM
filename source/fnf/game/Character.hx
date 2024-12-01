package fnf.game;

import fnf.backend.SndUtil;
import flixel.FlxG;
import flixel.util.FlxColor;
import fnf.display.AtlasSprite;

class Character extends AtlasSprite {
	public static var SING_ANIMS = [ 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT' ];

	public var name(default, null):String;
	public final isPlayer:Bool;

	public var healthColor(default, null):FlxColor;
	public var healthIcon(default, null):String;

	public var idleSuffix = '';
	public var singSuffix = '';
	public var specialSuffix = '';

	public var singDuration = 4.0;

	public var specialAnim = false;

	public var danceEvery = 2;
	public var danceIdle(default, null) = true;

	private var positionOffsets = [ 0.0, 0.0 ];
	private var animOffsets:Map<String, Array<Float>> = [];

	public function new(x = 0.0, y = 0.0, char = 'bf', player = false) {
		super(x, y);
		isPlayer = player;

		reloadCharacter(char);
	}

	public function reloadCharacter(char:String):Character {
		switch char {
			default:
				frames = Paths.getSparrowAtlas('game/characters/bf');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);

				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				animation.addByPrefix('hey', 'BF HEY!!', 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);
				animation.addByPrefix('hit', 'BF hit', 24, false);
				animation.addByPrefix('pre-attack', 'bf pre attack', 24, false);
				animation.addByPrefix('attack', 'boyfriend attack', 24, false);
				animation.addByPrefix('dodge', 'boyfriend dodge', 24, false);
		}
		dance();

		return this;
	}

	public function updateIdleAnim() {
		if (danceIdle != (danceIdle = !animation.exists('danceLeft$idleSuffix') || !animation.exists('danceRight$idleSuffix'))) {
			var numBeats:Float = danceEvery;
			if (danceIdle) numBeats /= 2;
			else numBeats *= 2;
			danceEvery = Math.floor(Math.max(numBeats, 1));
		}
	}

	override function playAnim(name:String, force = false, reversed = false, frame = 0) {
		super.playAnim(name, force, reversed, frame);
		if (getAnimName() != null) {
			var offsets = animOffsets.get(getAnimName()) ?? [ 0, 0 ];
			offset.set(offsets[0] - positionOffsets[0], offsets[1] - positionOffsets[1]);
		}
	}

	override function update(elapsed:Float) {
		var time = SndUtil.getAccuratePos(FlxG.sound.music);
		var stepDuration = 60 / Conductor.ME.bpm * 1000 / 4;
		var singFinished = time >= lastSingTime + stepDuration * singDuration;

		if ((specialAnim && isAnimFinished()) || singFinished) dance();

		super.update(elapsed);
	}

	var danced = false;
	public function dance() {
		if (!specialAnim) {
			if (!danceIdle) {
				danced = !danced;
				playAnim((danced ? 'danceRight' : 'danceLeft') + idleSuffix);
			} else
				playAnim('idle$idleSuffix');
		}
	}

	private var lastSingTime = -1.0;
	public function sing(key:Int) {
		playAnim(SING_ANIMS[key], true);
		lastSingTime = SndUtil.getAccuratePos(FlxG.sound.music);
	}
}
