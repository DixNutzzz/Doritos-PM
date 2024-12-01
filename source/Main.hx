import flixel.FlxG;
import flixel.FlxGame;
import openfl.events.Event;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();

		if (stage != null) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);
	}

	function init(?e:Event) {
		if (hasEventListener(Event.ADDED_TO_STAGE)) removeEventListener(Event.ADDED_TO_STAGE, init);

		addChild(new FlxGame(1280, 720, null, 60, 60, true, false));
		FlxG.mouse.useSystemCursor = true;

		FlxG.console.registerClass(fnf.backend.save.ClientPrefs);
		FlxG.console.registerClass(fnf.backend.Logger);

		fnf.backend.Conductor.ME = new fnf.backend.Conductor();

		// FlxG.switchState(() -> new fnf.ui.ImGuiState());
		FlxG.switchState(() -> new fnf.game.PlayState());
	}
}
