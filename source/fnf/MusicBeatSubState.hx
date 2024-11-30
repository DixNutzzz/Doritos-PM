package fnf;

import flixel.FlxSubState;

class MusicBeatSubState extends FlxSubState {
	public var curStep(default, null) = 0;
	public var curBeat(default, null) = 0;
	public var curMeasure(default, null) = 0;

	public function new() {
		super();
	}

	override function create() {
		super.create();

		Conductor.ME.onStepHit.add(stepHit);
		Conductor.ME.onBeatHit.add(beatHit);
		Conductor.ME.onMeasureHit.add(measureHit);
	}

	override function destroy() {
		Conductor.ME.onStepHit.remove(stepHit);
		Conductor.ME.onBeatHit.remove(beatHit);
		Conductor.ME.onMeasureHit.remove(measureHit);

		super.destroy();
	}

	function stepHit(step:Int) {}
	function beatHit(beat:Int) {}
	function measureHit(measure:Int) {}
}
