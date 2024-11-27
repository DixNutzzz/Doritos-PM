package fnf.backend;

import flixel.util.FlxSignal.FlxTypedSignal;

typedef BPMChangeEvent = {
	var time: {
		var step:Float;
		var ms:Float;
	}
	var bpm:Float;
	var stepDuration:Float;
}

class Conductor {
	private static var bpmChangeMap:Array<BPMChangeEvent> = [];
	private static var curBPMChange:BPMChangeEvent = null;

	public static var bpm (get, never):Null<Float>;
		@:noCompletion static inline function get_bpm() return curBPMChange?.bpm;

	public static var stepDuration (get, never):Null<Float>;
		@:noCompletion static inline function get_stepDuration() return curBPMChange?.stepDuration;

	public static final onBPMChange = new FlxTypedSignal<(oldBPM:Float, newBPM:Float)->Void>();
	public static final onStepHit = new FlxTypedSignal<(oldStep:Int, newStep:Int)->Void>();
	public static final onBeatHit = new FlxTypedSignal<(oldBeat:Int, newBeat:Int)->Void>();
	public static final onMeasureHit = new FlxTypedSignal<(oldMeasure:Int, newMeasure:Int)->Void>();

	public static var step(default, null):Float;
	public static var beat(default, null):Float;
	public static var measure(default, null):Float;

	public static var songPosition (default, set):Float;
		@:noCompletion static function set_songPosition(v) {
			var lastBPMChange = curBPMChange;
			for (event in bpmChangeMap) if (event.time.ms <= v) curBPMChange = event;
			if (lastBPMChange != curBPMChange) onBPMChange.dispatch(lastBPMChange.bpm, curBPMChange.bpm);

			var lastStep = Math.floor(step);
			step = curBPMChange.time.step + (v - curBPMChange.time.ms) / curBPMChange.stepDuration;
			var curStep = Math.floor(step);
			if (curStep != lastStep) {
				onStepHit.dispatch(lastStep, curStep);

				var lastBeat = Math.floor(beat);
				beat = step / 4;
				var curBeat = Math.floor(beat);
				if (curBeat != lastBeat) {
					onBeatHit.dispatch(lastBeat, curBeat);

					var lastMeasure = Math.floor(measure);
					measure = beat / 4;
					var curMeasure = Math.floor(measure);
					if (curMeasure != lastMeasure) onMeasureHit.dispatch(lastMeasure, curMeasure);
				}
			}

			return songPosition = v;
		}

	public static function getBPMAtTime(time:Float):Float {
		var result = 0.0;
		for (event in bpmChangeMap) if (event.time.ms <= time) result = event.bpm;
		return result;
	}
}
