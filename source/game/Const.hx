package game;

import haxe.ds.ReadOnlyArray;

class Const {
	public static final NOTE_DIRECTIONS:ReadOnlyArray<String> = [ 'left', 'down', 'up', 'right' ];

	public static final NOTE_COLORS:ReadOnlyArray<String> = [ 'purple', 'blue', 'green', 'red' ];

	public static inline var NOTE_SCALE = 0.7;

	public static inline var NOTE_WIDTH_UNSCALED = 160.0;

	public static inline var NOTE_WIDTH = NOTE_WIDTH_UNSCALED * NOTE_SCALE;
	public static inline var NOTE_WIDTH_DIV2 = NOTE_WIDTH / 2;

	public static inline var SUSTAIN_NOTE_HEIGHT = 44.0;

	public static inline var NOTE_HIT_WINDOW = 160.0;

	public static inline var NOTE_SPAWN_DELAY = 2000.0;

	public static inline var FUNNY_TEXT = 'NIGGA FUNKIN';
}
