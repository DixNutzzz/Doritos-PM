package fnf.game;

import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import fnf.backend.GcUtil;
import flixel.sound.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import fnf.backend.beatmap.Beatmap;
import fnf.backend.beatmap.BeatmapData;

class PlayState extends MusicBeatState {
	public var beatmap:BeatmapData;

	public var camGame:GameCamera;
	public var camHUD:HudCamera;

	/** Alias to `FlxG.sound.music` **/
	public var inst:FlxSound;

	public var strumLines:FlxTypedGroup<StrumLine>;

	override function create() {
		beatmap = Beatmap.get('test');
		Conductor.mapBPMChanges(beatmap);

		camGame = new GameCamera();
		FlxG.cameras.reset(camGame);

		camHUD = new HudCamera();
		FlxG.cameras.add(camHUD, false);

		strumLines = new FlxTypedGroup<StrumLine>();
		strumLines.cameras = [ camHUD ];
		add(strumLines);

		for (strumDat in beatmap.strumLines) {
			var strumLine = new StrumLine(strumDat.strumPos, strumDat.strumVisible, strumDat.notes, beatmap.noteKinds);
			if (strumDat.cpu) strumLine.cpuControlled = true;
			strumLines.add(strumLine);
		}

		FlxG.sound.playMusic(Paths.inst('test'));
		inst = FlxG.sound.music;

		super.create();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

		GcUtil.force();
		GcUtil.disable();
	}

	override function update(elapsed:Float) {
		Conductor.updatePosition();

		super.update(elapsed);
	}

	override function destroy() {
		GcUtil.enable();

		super.destroy();
	}

	function onKeyDown(e:KeyboardEvent) {
		var key = getKeyFromEvent(e);
		if (key != null) keyPress(key);
	}

	function onKeyUp(e:KeyboardEvent) {
		var key = getKeyFromEvent(e);
		if (key != null) keyRelease(key);
	}

	function getKeyFromEvent(e:KeyboardEvent):Null<Int> {
		if (e.altKey || e.ctrlKey) return null;

		return switch e.keyCode { // TODO: custom bindings
			case FlxKey.A | FlxKey.LEFT:  0;
			case FlxKey.S | FlxKey.DOWN:  1;
			case FlxKey.W | FlxKey.UP:    2;
			case FlxKey.D | FlxKey.RIGHT: 3;
			default:                      null;
		}
	}

	function keyPress(key:Int) {
		Conductor.updatePosition();

		for (strumLine in strumLines) if (!strumLine.cpuControlled) {
			strumLine.hitAllPossibleNotes(key);

			var strum = strumLine.members[key];
			if (strum?.animation?.name != 'confirm') strum.playAnim('pressed', true);
		}
	}

	function keyRelease(key:Int) {
		for (sl in strumLines) if (!sl.cpuControlled) sl.members[key]?.playAnim('static');
	}
}
