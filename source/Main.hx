import flixel.FlxGame;
import openfl.events.Event;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();

		game.backend.Logger.init();

		if (stage != null) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?e:Event) {
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		DeviceInfos.print();

		game.components.AtlasText.AlphaCharacter.loadAlphabetData();

		addChild(new FlxGame(1280, 720, game.play.PlayState, 144, 144, true, false));
		// addChild(new UsageInfo());
	}
}
