package fnf.game;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import fnf.backend.beatmap.Beatmap;
import fnf.backend.beatmap.BeatmapData;

@:structInit @:publicFields class PlayStateParams {
	var song = 'test';
	var difficulty = 'normal';
	var testingMode = false;
}

class PlayState extends MusicBeatState {
	// Param fields
	public var beatmap:BeatmapData;
	public var isTestingMode:Bool;

	public var camGame:GameCamera;
	public var camHUD:HUDCamera;

	public var strumLineNotes:FlxTypedSpriteGroup<Strum>;
	public var opponentStrums:FlxTypedGroup<Strum>;
	public var playerStrums:FlxTypedGroup<Strum>;

	public var notes:FlxTypedGroup<Note>;

	public function new(params:PlayStateParams) {
		super();

		// beatmap = Beatmap.get(params.song, params.difficulty);
		beatmap = Beatmap.createEmpty(params.song);
		isTestingMode = params.testingMode;
	}

	override function create() {
		camGame = new GameCamera();
		FlxG.cameras.reset(camGame);

		camHUD = new HUDCamera();
		FlxG.cameras.add(camHUD, false);

		createStrums();

		createNotes();

		startHUDIntro();

		super.create();
	}

	private var _strumsCreated = false;
	function createStrums() {
		if (_strumsCreated) {
			Logger.warn('Strums already created');
			return;
		}
		_strumsCreated = true;

		strumLineNotes = new FlxTypedSpriteGroup<Strum>(0, 50);
		strumLineNotes.cameras = [ camHUD ];
		add(strumLineNotes);

		var strumGroups = [ opponentStrums, playerStrums ];
		for (player in 0...2) {
			for (data in 0...4) {
				var strum = new Strum(data, player).reloadNote();
				strum.playerPosition();
				strumLineNotes.add(strum);
				strumGroups[player]?.add(strum);
			}
		}

		strumLineNotes.screenCenter(X);
	}

	private var _notesCreated = false;
	function createNotes() {
		if (_notesCreated) {
			Logger.warn('Notes already created');
			return;
		}
		_notesCreated = true;

		notes = new FlxTypedGroup<Note>();
		notes.cameras = [ camHUD ];
		add(notes);

		for (dat in beatmap.notes.list) {
			var note = new Note(dat.t, dat.p, dat.s, beatmap.notes.kinds[dat.k]).reloadNote();
			notes.add(note);

			for (sustain in note.createTail()) notes.add(sustain);
		}
	}

	private var _hudIntroStarted = false;
	function startHUDIntro() {
		if (_hudIntroStarted) {
			Logger.warn('HUD intro already started');
			return;
		}
		_hudIntroStarted = true;

		camHUD.zoom = 1.1;

		FlxTween.tween(camHUD, { zoom: 1.0 }, 1, { ease: FlxEase.circOut });

		for (strum in strumLineNotes) {
			strum.y -= 50;
			strum.alpha = 0;
			FlxTween.tween(strum, { y: strum.y + 50, alpha: 1 }, 1, {
				ease: FlxEase.circOut,
				startDelay: strum.player == 0 ? 0.2 * strum.noteData : 0.2 * (3 - strum.noteData)
			});
		}
	}

	override function update(elapsed:Float) {
		notes.forEachAlive(note -> {
			var strumGroups = [ opponentStrums, playerStrums ];
			var strumGroup = strumGroups[note.player];
			if (strumGroup == null) return;

			var strum = strumGroup.members[note.strum];
			if (strum == null) return;

			note.followStrum(strum, beatmap.scrollSpeed);
			note.clipToStrum(strum);
		});

		super.update(elapsed);
	}
}
