package game.play;

import game.backend.Controls;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import game.data.song.SongData;
import flixel.text.FlxText;
import flixel.FlxG;
import game.components.AtlasText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

/** PLACEHOLDER **/
class PauseSubState extends MusicBeatSubState {
	private var _bg:FlxSprite;

	public var menuItemLabels:Array<String>;
	public var menuItemLabelsByDefault = [
		'Resume',
		'Restart Song',
		// 'Change Difficulty',
		// 'Options',
		// 'Exit to Menu'
	];

	private var _menuItems:FlxTypedGroup<AtlasText>;

	private var _levelTitle:FlxText;
	private var _levelDifficulty:FlxText;

	private var _selection = 0;

	private var _song:SongData;
	private var _difficulty:String;

	public function new(song:SongData, difficulty:String) {
		super();
		menuItemLabels = menuItemLabelsByDefault.copy();

		_song = song;
		_difficulty = difficulty;

		openCallback = onOpen;

		_bg = new FlxSprite().makeGraphic(1, 1, 0xff000000);
		_bg.setGraphicSize(FlxG.width, FlxG.height);
		_bg.updateHitbox();
		add(_bg);

		_levelTitle = new FlxText(20, 15, 0, _song.meta.song);
		_levelTitle.setFormat(Paths.font('vcr.ttf'), 32);
		add(_levelTitle);

		_levelDifficulty = new FlxText(_levelTitle.x, _levelTitle.y + _levelTitle.size, 0, _difficulty.toUpperCase());
		_levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		add(_levelDifficulty);

		_menuItems = new FlxTypedGroup<AtlasText>();
		add(_menuItems);

		resetMenuItems();
	}

	private function onOpen() {
		_bg.alpha = _levelTitle.alpha = _levelDifficulty.alpha = 0;

		FlxTween.tween(_bg, { alpha: 0.6 }, 0.4, { ease: FlxEase.quartInOut });
		FlxTween.tween(_levelTitle, { alpha: 1, y: 20 }, 0.4, { ease: FlxEase.quartInOut, startDelay: 0.3 });
		FlxTween.tween(_levelDifficulty, { alpha: 1, y: 20 }, 0.4, { ease:FlxEase.quartInOut, startDelay: 0.5 });

		resetMenuItems();
	}

	private function changeSelection(delta = 0) {
		_selection = FlxMath.wrap(_selection + delta, 0, _menuItems.length - 1);

		for (i => menuItem in _menuItems) {
			menuItem.targetY = i - _selection;
			menuItem.alpha = 0.6;
			if (menuItem.targetY == 0) {
				menuItem.alpha = 1;
			}
		}

		if (FlxG.state.subState == this)
			FlxG.sound.play(Paths.sound('menu/scroll'), 0.4);
	}

	private function resetMenuItems() {
		_menuItems.kill();
		_menuItems.clear();
		_menuItems.revive();

		for (i => label in menuItemLabels) {
			var menuItem = _menuItems.recycle(AtlasText);
			menuItem.startPosition.set(90, 320);
			menuItem.text = label;
			menuItem.isMenuItem = true;
			menuItem.targetY = i;
			_menuItems.add(menuItem);
		}

		changeSelection(-_selection);
	}

	override function update(elapsed:Float) {
		if (FlxG.keys.justPressed.ESCAPE) {
			close();
			return;
		}

		var deltaSelection = 0;

		if (Controls.turboPressed(UI_UP)) deltaSelection--;
		if (Controls.turboPressed(UI_DOWN)) deltaSelection++;
		if (FlxG.mouse.wheel != 0) deltaSelection -= FlxMath.signOf(FlxG.mouse.wheel);

		if (deltaSelection != 0) changeSelection(deltaSelection);

		if (Controls.justPressed(ACCEPT)) {
			switch menuItemLabels[_selection] {
				case 'Resume': close();
				case 'Restart Song': FlxG.resetState();
			}
		}

		super.update(elapsed);
	}
}
