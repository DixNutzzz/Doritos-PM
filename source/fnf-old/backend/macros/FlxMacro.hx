package fnf.backend.macros;

import haxe.macro.Context;
import haxe.macro.Expr.Field;

class FlxMacro {
	public static macro function buildFlxObject():Array<Field> {
		var pos = Context.currentPos();
		var cls = Context.getLocalClass().get();
		var fields = Context.getBuildFields();

		for (field in fields) {
			if (field.name != 'getScreenPosition') continue;

			switch field.kind {
				case FFun(f):
					f.expr = macro {
						if (result == null)
							result = FlxPoint.get();

						if (camera == null)
							camera = FlxG.camera;

						result.set(x, y);
						if (pixelPerfectPosition)
							result.floor();

						result = result.subtract(camera.scroll.x * scrollFactor.x, camera.scroll.y * scrollFactor.y);
						if (altering && camera != null) result = camera.alterPosition(result, this);
						return result;
					}

				default:
			}

			break;
		}

		fields.push({
			name: 'altering',
			doc: '',
			access: [APublic],
			kind: FVar(macro : Bool, macro $v{true}),
			pos: pos
		});

		return fields;
	}

	public static macro function buildFlxCamera():Array<Field> {
		var pos = Context.currentPos();
		var cls = Context.getLocalClass().get();
		var fields = Context.getBuildFields();

		fields.push({
			name: 'alterPosition',
			doc: '',
			access: [APublic],
			kind: FFun({
				args: [ {
					name: 'result',
					type: macro : flixel.math.FlxPoint
				}, {
					name: 'object',
					type: macro : flixel.FlxObject
				} ],
				ret: macro : flixel.math.FlxPoint,
				expr: macro {
					return result;
				}
			}),
			pos: pos
		});

		return fields;
	}

	public static macro function buildFlxSprite(): Array<Field> {
		var pos = Context.currentPos();
		var fields = Context.getBuildFields();

		for (field in fields) {
			switch field.kind {
				case FFun(f):
					switch field.name {
						case 'drawSimple':
							f.expr = macro {
								getScreenPosition(_point, camera).subtractPoint(offset);
								if (isPixelPerfectRender(camera)) _point.floor();

								_point.copyToFlash(_flashPoint);
								camera.copyPixels(_frame, framePixels, _flashRect, _flashPoint, colorTransform, blend, antialiasing && (fnf.backend.save.ClientPrefs.data.antialiasing || forceAntialiasing));
							}

						case 'drawComplex':
							f.expr = macro {
								_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
								_matrix.translate(-origin.x, -origin.y);
								_matrix.scale(scale.x, scale.y);

								if (bakedRotationAngle <= 0) {
									updateTrig();

									if (angle != 0) _matrix.rotateWithTrig(_cosAngle, _sinAngle);
								}

								getScreenPosition(_point, camera).subtractPoint(offset);
								_point.add(origin.x, origin.y);
								_matrix.translate(_point.x, _point.y);

								if (isPixelPerfectRender(camera)) {
									_matrix.tx = Math.floor(_matrix.tx);
									_matrix.ty = Math.floor(_matrix.ty);
								}

								camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing && (fnf.backend.save.ClientPrefs.data.antialiasing || forceAntialiasing), shader);
							}
				}

				default:
			}
		}

		fields.push({
			name: 'forceAntialiasing',
			access: [ APublic ],
			kind: FVar(macro : Bool, macro $v{false}),
			pos: pos
		});

		return fields;
	}
}
