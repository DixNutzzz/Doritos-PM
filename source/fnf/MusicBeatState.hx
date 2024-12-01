package fnf;

import flixel.addons.transition.FlxTransitionableState;

class MusicBeatState extends FlxTransitionableState {
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
