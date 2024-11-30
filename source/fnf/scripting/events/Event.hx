package fnf.scripting.events;

import haxe.Constraints.Function;

abstract class Event {
	public final type:String;
	private var expr:Function;

	public var cancelled = false;
	public var shouldPropagate = true;
}
