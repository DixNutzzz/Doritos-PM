package fnf.scripting.events;

class StateEvent extends Event {
	public static inline var INIT = 'stateInit';
	public static inline var CREATE = 'stateCreate';

	public static inline var UPDATE_PRE = 'stateUpdatePre';
	public static inline var UPDATE_POST = 'statePUpdatePost';

	public static inline var DESTROY = 'stateDestroy';

	public final state:MusicBeatState;

	public function new(state:MusicBeatState) {
		this.state = state;
	}
}
