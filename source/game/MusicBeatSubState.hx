package game;

import game.backend.Conductor;
import flixel.FlxSubState;

class MusicBeatSubState extends FlxSubState {
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

	private function stepHit(step:Int) {}
	private function beatHit(beat:Int) {}
	private function measureHit(measure:Int) {}
}
