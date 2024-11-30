package fnf.scripting.events;

import fnf.game.notes.Note;

class NoteEvent extends Event {
	public static inline var CREATE = 'noteCreate';
	public static inline var SPAWN = 'noteSpawn';
	public static inline var UPDATE = 'noteUpdate';
	public static inline var HIT = 'noteHit';
	public static inline var MISS = 'noteMiss';

	public final note:Note;

	public var texture = 'default';
	public var scale = 1.0;

	public function new(note:Note) {
		this.note = note;
	}
}
