package game.play;

import flxanimate.FlxAnimate;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.animation.FlxAnimationController;
import game.components.AtlasSprite;

class Character extends AtlasSprite {
	public var curCharacter(default, null):String;
	public var isPlayer(default, null):Bool;

	public var healthIcon(default, null):String;
	public var healthColor(default, null):Int;

	private var _positionOffset = [ 0.0, 0.0 ];

	// IDK if it's good idea
	private var _cachedSpriteSheets:Map<String, { frames:FlxFramesCollection, animation:FlxAnimationController }> = [];
	private var _cachedAnimates:Map<String, FlxAnimate> = [];

	public function new(x = 0.0, y = 0.0, char = 'bf', player = false) {
		super(x, y);

		isPlayer = player;
		reloadChar(char);
	}

	public function reloadChar(char:String):Character {
		curCharacter = char;

		// prevent controllers from destroying
		animation = null;
		animate = null;

		switch char {
			case _:
				char = 'bf';
				if (_cachedSpriteSheets.exists(char)) {
					var spriteSheet = _cachedSpriteSheets[char];
					frames = spriteSheet.frames;
					animation = spriteSheet.animation;
				}
				else if (_cachedAnimates.exists(char)) animate = _cachedAnimates[char];
				else loadAtlas('characters/bf');
				antialiasing = Options.data.antialiasing;

				flipX = !isPlayer;

				addAnim('idle', 'BF idle dance', 24, false);
				addAnim('singUP', 'BF NOTE UP0', 24, false);
				addAnim('singLEFT', 'BF NOTE LEFT0', 24, false);
				addAnim('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				addAnim('singDOWN', 'BF NOTE DOWN0', 24, false);
				addAnim('singUPmiss', 'BF NOTE UP MISS', 24, false);
				addAnim('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				addAnim('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				addAnim('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				addAnim('hey', 'BF HEY!!', 24, false);
				addAnim('scared', 'BF idle shaking', 24, false);
				addAnim('hit', 'BF hit', 24, false);
				addAnim('pre-attack', 'bf pre attack', 24, false);
				addAnim('attack', 'boyfriend attack', 24, false);
				addAnim('dodge', 'boyfriend dodge', 24, false);

				addOffset('idle', -5);
				addOffset('singUP', -39, 27);
				addOffset('singLEFT', 6, -7);
				addOffset('singRIGHT', -48, -6);
				addOffset('singDOWN', -17, -50);
				addOffset('singUPmiss', -35, 27);
				addOffset('singLEFTmiss', 6, 19);
				addOffset('singRIGHTmiss', -44, 22);
				addOffset('singDOWNmiss', -16, -19);
				addOffset('hey', -3, 6);
				addOffset('scared', -6, 1);
				addOffset('hit', 13, 19);
				addOffset('pre-attack', -47, -36);
				addOffset('attack', 289, 270);
				addOffset('dodge', -8, -13);
		}

		if (isAnimate() && !_cachedAnimates.exists(char)) _cachedAnimates[char] = animate;
		else if (!isAnimate() && !_cachedSpriteSheets.exists(char)) _cachedSpriteSheets[char] = {
			frames: frames,
			animation: animation
		}

		return this;
	}

	public function dance() {
		playAnim('idle', true);
	}

	public function sing(key:Int) {
		playAnim('sing${Const.NOTE_DIRECTIONS[key].toUpperCase()}', true);
	}

	override function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		super.playAnim(name, force, reversed, frame);
		offset.subtract(_positionOffset[0], _positionOffset[1]);
	}
}
