package fnf.backend;

import openfl.media.SoundChannel;
import flixel.sound.FlxSound;
import haxe.extern.EitherType;
import flixel.FlxG;
import fnf.backend.beatmap.BeatmapData;
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
	public static inline var NOTE_HIT_WINDOW = 160;

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
			if (lastBPMChange != curBPMChange && lastBPMChange != null) onBPMChange.dispatch(lastBPMChange.bpm, curBPMChange.bpm);

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

	public static function mapBPMChanges(beatmap:BeatmapData) {
		bpmChangeMap = [ {
			time: {
				step: 0,
				ms: 0
			},
			bpm: beatmap.bpm,
			stepDuration: 60 / beatmap.bpm * 1000 / 4
		} ];

		var curBPM = beatmap.bpm;
		for (e in beatmap.events) if (beatmap.eventKinds[e.k] == 'BPM Change') {
			var newBPM = beatmap.eventParams[e.p[0]];
			if (newBPM == curBPM) continue;

			var lastEvent = bpmChangeMap[bpmChangeMap.length - 1];
			bpmChangeMap.push({
				time: {
					step: lastEvent.time.step + (e.t - lastEvent.time.ms) / lastEvent.stepDuration,
					ms: e.t
				},
				bpm: newBPM,
				stepDuration: 60 / newBPM * 1000 / 4
			});
		}
	}

	public static function updatePosition(?soundOrChannel:EitherType<FlxSound, SoundChannel>) @:privateAccess {
		if (soundOrChannel is FlxSound) soundOrChannel = (soundOrChannel : FlxSound)._channel;
		if (soundOrChannel == null) soundOrChannel = FlxG.sound.music?._channel;

		if (soundOrChannel == null) songPosition = 0;
		else songPosition = (soundOrChannel : SoundChannel).position;
	}
}
