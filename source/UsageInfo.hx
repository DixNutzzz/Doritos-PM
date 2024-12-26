import game.backend.Options;
import flixel.system.FlxAssets;
import openfl.text.TextFormat;
import flixel.util.FlxStringUtil;
import game.utils.MemoryUtils;
import flixel.FlxG;
import game.utils.MathUtils;
import openfl.text.TextField;

class UsageInfo extends TextField {
	private var _lastFPS:Null<Float>;
	private var _lastRAM:Null<Float>;
	private var _lastVRAM:Null<Float>;

	public function new() {
		super();
		x = 10;
		y = 2;

		defaultTextFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, 0xffffffff);
	}

	override function __enterFrame(deltaTime:Int) {
		if (!visible || alpha <= 0.05) return;

		htmlText = '';

		if (Options.data.showFPS) {
			if (_lastFPS == null) _lastFPS = 1 / FlxG.elapsed;
			else _lastFPS = MathUtils.fpsSensitiveLerp(_lastFPS, 1 / FlxG.elapsed, 0.25);

			if (_lastFPS < Options.data.framerate) htmlText += '<font color="#ff0000">${_lastFPS} FPS</font>';
			else htmlText += '${_lastFPS} FPS';
			htmlText += '\n';
		}

		if (Options.data.showRAM) {
			if (_lastRAM == null) _lastRAM = Math.abs(MemoryUtils.getUsedRAM());
			else _lastRAM = MathUtils.fpsSensitiveLerp(_lastRAM, Math.abs(MemoryUtils.getUsedRAM()), 0.25);

			if (_lastRAM > 1073741824) htmlText += '<font color="#ff0000">RAM: ${FlxStringUtil.formatBytes(_lastRAM)}</font>';
			else htmlText += 'RAM: ${FlxStringUtil.formatBytes(_lastRAM)}';
			htmlText += '\n';
		}

		if (Options.data.showVRAM) {
			if (_lastVRAM == null) _lastVRAM = Math.abs(MemoryUtils.getUsedVRAM());
			else _lastVRAM = MathUtils.fpsSensitiveLerp(_lastVRAM, Math.abs(MemoryUtils.getUsedVRAM()), 0.25);

			if (_lastVRAM > 2147483648) htmlText += '<font color="#ff0000">VRAM: ${FlxStringUtil.formatBytes(_lastVRAM)}</font>';
			else htmlText += 'VRAM: ${FlxStringUtil.formatBytes(_lastVRAM)}';
			htmlText += '\n';
		}

		super.__enterFrame(deltaTime);
	}
}
