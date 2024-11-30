package fnf.scripting.events;

import fnf.game.notes.Strum;

class StrumEvent extends Event {
	public static inline var CREATE = 'strumCreate';
	public static inline var ANIM_PLAY = 'strumAnimPlay';

	public final strum:Strum;

	public var texture = 'default';
	public var scale = 1.0;

	public function new(strum:Strum) {
		this.strum = strum;
	}
}
