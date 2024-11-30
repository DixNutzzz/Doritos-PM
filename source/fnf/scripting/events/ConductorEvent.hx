package fnf.scripting.events;

class ConductorEvent extends Event {
	public static inline var BPM_CHANGE = 'conductorBPMChange';

	public static inline var STEP_HIT = 'conductorStepHit';
	public static inline var BEAT_HIT = 'conductorBeatHit';
	public static inline var MEASURE_HIT = 'conductorMeasureHit';

	public final conductor:Conductor;

	public function new(conductor:Conductor) {
		this.conductor = conductor;
	}
}
