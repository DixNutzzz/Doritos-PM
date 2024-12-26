package game.components;

import flixel.animation.FlxAnimationController;
import flixel.util.FlxDestroyUtil;
import haxe.io.Path;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import flxanimate.FlxAnimate;
import flixel.FlxSprite;

class AtlasSprite extends FlxSprite {
	public var animate(default, null):FlxAnimate;

	public var animOffsets:Map<String, Array<Float>> = [];

	public inline function isAnimate():Bool {
		return animate != null;
	}

	public function new(x = 0.0, y = 0.0, ?assetKey:String) {
		super(x, y);
		if (assetKey != null) loadAtlas(assetKey);
	}

	public function loadAtlas(key:String):AtlasSprite {
		animation = FlxDestroyUtil.destroy(animation);
		animate = FlxDestroyUtil.destroy(animate);

		var imagePath = Paths.image(key);

		var txtPath = Paths.file('images/${key}.txt', TEXT);
		if (FlxG.assets.exists(txtPath, TEXT)) {
			animation = new FlxAnimationController(this);
			frames = FlxAtlasFrames.fromSpriteSheetPacker(imagePath, txtPath);
			return this;
		}

		var xmlPath = Paths.file('images/${key}.xml', TEXT);
		if (FlxG.assets.exists(xmlPath, TEXT)) {
			animation = new FlxAnimationController(this);
			frames = FlxAtlasFrames.fromSparrow(imagePath, xmlPath);
			return this;
		}

		var jsonPath = Paths.file('images/${key}.json', TEXT);
		if (FlxG.assets.exists(jsonPath, TEXT)) {
			animation = new FlxAnimationController(this);
			frames = FlxAtlasFrames.fromTexturePackerJson(imagePath, jsonPath);
			return this;
		}

		var animationPath = Paths.file('images/${key}/Animation.json', TEXT);
		if (FlxG.assets.exists(animationPath, TEXT)) {
			animate = new FlxAnimate();
			animate.loadAtlas(Path.directory(animationPath));
			return this;
		}

		var zipPath = Paths.file('images/${key}.zip', TEXT);
		if (FlxG.assets.exists(zipPath, BINARY)) {
			animate = new FlxAnimate();
			animate.loadAtlas(zipPath);
			return this;
		}

		return this;
	}

	public function addAnim(name:String, anim:String, framerate = 30.0, looped = true, flipX = false, flipY = false) {
		if (isAnimate()) animate.anim.addBySymbol(name, anim, framerate, looped);
		else animation.addByPrefix(name, anim, framerate, looped);
	}

	public function addAnimByIndices(name:String, anim:String, indices:Array<Int>, framerate = 30.0, looped = true) {
		if (isAnimate()) animate.anim.addBySymbolIndices(name, anim, indices, framerate, looped);
		else animation.addByIndices(name, anim, indices, '', framerate, looped);
	}

	public function addOffset(name:String, x = 0.0, y = 0.0) {
		animOffsets[name] = [ x, y ];
	}

	public function playAnim(name:String, force = false, reversed = false, frame = 0) {
		if (isAnimate()) animate.anim.play(name, force, reversed, frame);
		else animation.play(name, force, reversed, frame);

		var offsets = animOffsets.get(name);
		if (offsets != null) offset.set(offsets[0], offsets[1]);
		else offset.set();
	}

	public function getAnimName():Null<String> {
		if (isAnimate()) return animate.anim.curSymbol?.name;
		else return animation.name;
	}

	public function isAnimFinished():Bool {
		if (isAnimate()) return animate.anim.finished;
		else return animation.finished;
	}

	public function hasAnim(name:String):Bool {
		if (isAnimate()) return animate.anim.getByName(name) != null;
		else return animation.exists(name);
	}

	override function draw() {
		if (isAnimate()) {
			copyAnimateValues();
			animate.draw();
		}
		else super.draw();
	}

	private inline function copyAnimateValues() {
		animate.alpha = alpha;
		animate.angle = angle;
		animate.antialiasing = antialiasing;
		animate.blend = blend;
		animate.cameras = cameras;
		animate.clipRect = clipRect;
		animate.colorTransform = animate.colorTransform;
		animate.flipX = flipX;
		animate.flipY = flipY;
		animate.offset.copyFrom(offset);
		animate.origin.copyFrom(origin);
		animate.pixelPerfectPosition = pixelPerfectPosition;
		animate.pixelPerfectRender = pixelPerfectRender;
		animate.scale.copyFrom(scale);
		animate.scrollFactor.copyFrom(scrollFactor);
		animate.shader = shader;
		animate.useColorTransform = useColorTransform;
		animate.visible = visible;
		animate.x = x;
		animate.y = y;
	}
}
