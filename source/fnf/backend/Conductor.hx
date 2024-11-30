package fnf.backend;

import fnf.backend.beatmap.BeatmapData;
import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.media.SoundChannel;
import flixel.sound.FlxSound;
import flixel.util.typeLimit.OneOfThree;

typedef BPMChangeEvent = {
	var time: {
		var ms:Float;
		var step:Float;
	}
	var bpm:Float;
	var beatsPerMeasure:Float;
	var stepsPerBeat:Float;
}

class Conductor {
	public static var ME:Conductor;

	private var bpmChangeMap:Array<BPMChangeEvent> = [];
	private var curEvent:BPMChangeEvent;

	public final onBPMChange = new FlxTypedSignal<(oldBPM:Float, newBPM:Float)->Void>();
	public final onStepHit = new FlxTypedSignal<Int->Void>();
	public final onBeatHit = new FlxTypedSignal<Int->Void>();
	public final onMeasureHit = new FlxTypedSignal<Int->Void>();

	public var bpm(get, never):Null<Float>;
		@:noCompletion inline function get_bpm() return curEvent?.bpm;

	public var beatsPerMeasure(get, never):Null<Float>;
		@:noCompletion inline function get_beatsPerMeasure() return curEvent?.beatsPerMeasure;

	public var stepsPerBeat(get, never):Null<Float>;
		@:noCompletion inline function get_stepsPerBeat() return curEvent?.stepsPerBeat;

	public var step(default, null) = 0.0;
	public var beat(default, null) = 0.0;
	public var measure(default, null) = 0.0;

	public function new() {}

	public function uploadBeatmap(beatmap:BeatmapData) {
		bpmChangeMap = [ {
			time: { ms: 0, step: 0 },
			bpm: beatmap.meta.bpm,
			beatsPerMeasure: beatmap.meta.beatsPerMeasure,
			stepsPerBeat: beatmap.meta.stepsPerBeat
		} ];
		for (e in beatmap.events) if (e.k == 'BPM Change' && e.p[0] is Float && e.p[1] is Float && e.p[2] is Float) {
			var stepDuration = 60 / bpmChangeMap[bpmChangeMap.length - 1].bpm * 1000 / 4;
			bpmChangeMap.push({
				time: {
					ms: e.t,
					step: (e.t - bpmChangeMap[bpmChangeMap.length - 1].time.ms) / stepDuration
				},
				bpm: e.p[0],
				beatsPerMeasure: e.p[1],
				stepsPerBeat: e.p[2]
			});
		}
	}

	public function update(timeOrSoundOrChannel:OneOfThree<Float, FlxSound, SoundChannel>) {
		if (timeOrSoundOrChannel is FlxSound) timeOrSoundOrChannel = @:privateAccess (timeOrSoundOrChannel : FlxSound)._channel.position;
		if (timeOrSoundOrChannel is SoundChannel) timeOrSoundOrChannel = (timeOrSoundOrChannel : SoundChannel).position;

		var time:Float = timeOrSoundOrChannel;

		var lastEvent = curEvent;
		curEvent = getEventAtTime(time);

		if (curEvent != lastEvent && lastEvent != null) onBPMChange.dispatch(lastEvent.bpm, curEvent.bpm);

		var lastStep = Math.floor(step);
		var floorStep = Math.floor(step = curEvent.time.step + (time - curEvent.time.ms) / (60 / curEvent.bpm * 1000 / 4));
		if (floorStep > lastStep) {
			for (i in lastStep...floorStep) onStepHit.dispatch(i);

			var lastBeat = Math.floor(beat);
			var floorBeat = Math.floor(beat = step / stepsPerBeat);
			if (floorBeat > lastBeat) {
				for (i in lastBeat...floorBeat) onBeatHit.dispatch(i);

				var lastMeasure = Math.floor(measure);
				var floorMeasure = Math.floor(measure = beat / beatsPerMeasure);
				if (floorMeasure > lastMeasure) {
					for (i in lastMeasure...floorMeasure) onMeasureHit.dispatch(i);
				}
			}
		}
	}

	public function getEventAtTime(time:Float):BPMChangeEvent {
		var result:BPMChangeEvent = null;
		for (event in bpmChangeMap) if (event.time.ms <= time) result = event;
		return result;
	}
}
