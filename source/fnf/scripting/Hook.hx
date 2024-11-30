package fnf.scripting;

import fnf.scripting.events.Event;

class Hook {
	final t:String;
	final f:Event->Void;
	private function new(t:String, f:Event->Void) {
		this.t = t;
		this.f = f;
	}

	private static var _hooks = new List<Hook>();
	public static function add(type:String, method:Event->Void) {
		if (has(type, method)) return;
		_hooks.add(new Hook(type, method));
	}

	public static function remove(type:String, method:Event->Void) {
		for (h in _hooks) if (h.t == type && h.f == method) _hooks.remove(h);
	}

	public static function has(type:String, method:Event->Void) {
		for (h in _hooks) if (h.t == type && h.f == method) return true;
		return false;
	}

	public static function call(type:String, event:Event) {
		for (h in _hooks) if (h.t == type) h.f(event);
	}
}
