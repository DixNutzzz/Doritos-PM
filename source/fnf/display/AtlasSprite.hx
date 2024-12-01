package fnf.display;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;
import flxanimate.FlxAnimate;
import flixel.FlxSprite;

class AtlasSprite extends FlxSprite {
	private var animate:ChildAnimate;

	public inline function isAnimate():Bool {
		return animate != null;
	}

	public function new(x = 0.0, y = 0.0, ?atlasPath:String) {
		super(x, y);
		if (atlasPath != null) loadAtlas(atlasPath);
	}

	public function loadAtlas(key:String):AtlasSprite {
		if (animate != null) {
			animate.destroy();
			animate = null;
		}

		var xmlPath = Paths.getPath('images/$key.xml', TEXT);
		if (Assets.exists(xmlPath, TEXT)) {
			frames = FlxAtlasFrames.fromSparrow(Paths.image(key), xmlPath);
			return this;
		}

		var txtPath = Paths.getPath('images/$key.txt', TEXT);
		if (Assets.exists(txtPath, TEXT)) {
			frames = FlxAtlasFrames.fromSpriteSheetPacker(Paths.image(key), txtPath);
			return this;
		}

		var jsonPath = Paths.getPath('images/$key.json', TEXT);
		if (Assets.exists(jsonPath, TEXT)) {
			frames = FlxAtlasFrames.fromTexturePackerJson(Paths.image(key), jsonPath);
			return this;
		}

		var zipPath = Paths.getPath('images/$key.zip', BINARY);
		if (Assets.exists(zipPath, BINARY)) {
			animate = new ChildAnimate(this);
			animate.loadAtlas(zipPath);
			return this;
		}

		var folderPath = Paths.getFolderPath('images/$key');
		if (Assets.exists('${folderPath}/Animation.json', TEXT)) {
			animate = new ChildAnimate(this);
			animate.loadAtlas(Paths.getFolderPath('images/$key'));
			return this;
		}

		return this;
	}

	public function addAnim(name:String, anim:String, ?indices:Array<Int>, frameRate = 30, looped = false) {
		if (indices == null) indices = [];

		if (isAnimate()) {
			if (indices.length == 0) animate.anim.addBySymbol(name, anim, frameRate, looped);
			else animate.anim.addBySymbolIndices(name, anim, indices, frameRate, looped);
		}
		else {
			if (indices.length == 0) animation.addByPrefix(name, anim, frameRate, looped);
			else animation.addByIndices(name, anim, indices, '', frameRate, looped);
		}
	}

	public function playAnim(name:String, force = false, reversed = false, frame = 0) {
		if (isAnimate()) animate.anim.play(name, force, reversed, frame);
		else animation.play(name, force, reversed, frame);
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
		if (isAnimate()) return animate.anim.existsByName(name);
		else return animation.exists(name);
	}
}

class ChildAnimate extends FlxAnimate {
	private var sprite:AtlasSprite;

	public function new(parent:AtlasSprite) {
		super();
		sprite = parent;
	}

	override function draw() {
		if (alpha <= 0) return;

		parseElement(anim.curInstance, anim.curFrame, sprite._matrix, sprite.colorTransform, true);
		if (showPivot) drawLimb(_pivot, new FlxMatrix(1,0,0,1, sprite.origin.x, sprite.origin.y));
	}

	override function drawLimb(limb:FlxFrame, _matrix:FlxMatrix, ?colorTransform:ColorTransform) {
		if (sprite.alpha == 0 || colorTransform != null && (colorTransform.alphaMultiplier == 0 || colorTransform.alphaOffset == -255) || limb == null || limb.type == EMPTY)
			return;

		for (camera in cameras) {
			FlxAnimate.rMatrix.identity();
			limb.prepareMatrix(FlxAnimate.rMatrix);
			FlxAnimate.rMatrix.concat(_matrix);
			if (!camera.visible || !camera.exists || !limbOnScreen(limb, _matrix, camera)) return;

			sprite.getScreenPosition(_point, camera).subtractPoint(sprite.offset);
			FlxAnimate.rMatrix.translate(-sprite.origin.x, -sprite.origin.y);
			if (limb.name != "pivot") FlxAnimate.rMatrix.scale(scale.x, scale.y);
			else FlxAnimate.rMatrix.a = FlxAnimate.rMatrix.d = 0.7 / camera.zoom;

			_point.addPoint(sprite.origin);
			if (sprite.isPixelPerfectRender(camera)) _point.floor();

			FlxAnimate.rMatrix.translate(_point.x, _point.y);
			camera.drawPixels(limb, null, FlxAnimate.rMatrix, colorTransform, sprite.blend, sprite.antialiasing);
			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
		// doesnt work, needs to be remade
		//#if FLX_DEBUG
		//if (FlxG.debugger.drawDebug)
		//	drawDebug();
		//#end
	}

	override function limbOnScreen(limb:FlxFrame, m:FlxMatrix, ?camera:FlxCamera):Bool {
		if (camera == null) camera = FlxG.camera;

		var minX = sprite.x + m.tx - sprite.offset.x - sprite.scrollFactor.x * camera.scroll.x;
		var minY = sprite.y + m.ty - sprite.offset.y - sprite.scrollFactor.y * camera.scroll.y;

		var radiusX =  limb.frame.width * Math.max(1, m.a);
		var radiusY = limb.frame.height * Math.max(1, m.d);
		var radius = Math.max(radiusX, radiusY);
		radius *= FlxMath.SQUARE_ROOT_OF_TWO;
		minY -= radius;
		minX -= radius;
		radius *= 2;

		_point.set(minX, minY);

		return camera.containsPoint(_point, radius, radius);
	}
}
