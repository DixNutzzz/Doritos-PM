package fnf;

import flixel.addons.transition.FlxTransitionableState;

class MusicBeatState extends FlxTransitionableState {
	public var curStep(default, null) = 0;
	public var curBeat(default, null) = 0;
	public var curMeasure(default, null) = 0;

	public function new() {
		super();
	}

	override function create() {
		super.create();

		Conductor.onStepHit.add(stepHit);
		Conductor.onBeatHit.add(beatHit);
		Conductor.onMeasureHit.add(measureHit);
	}

	override function destroy() {
		Conductor.onStepHit.remove(stepHit);
		Conductor.onBeatHit.remove(beatHit);
		Conductor.onMeasureHit.remove(measureHit);

		super.destroy();
	}

	function stepHit(oldStep:Int, newStep:Int) {}
	function beatHit(oldBeat:Int, newBeat:Int) {}
	function measureHit(oldMeasure:Int, newMeasure:Int) {}
}
