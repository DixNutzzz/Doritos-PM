package fnf.backend.beatmap;

typedef BeatmapData = {
	var meta:BeatmapMetaData;
	var events:Array<EventData>;

	var scrollSpeed:Float;
	var noteKinds:Array<String>;
	var strumLines:Array<StrumLineData>;
	var stage:String;
}

typedef BeatmapMetaData = {
	var song:String;
	var bpm:Float;
	var beatsPerMeasure:Float;
	var stepsPerBeat:Float;
	var needsVoices:Bool;
	var offset:Float;
}

typedef EventData = {
	var t:Float;
	var k:String;
	var p:Array<Dynamic>;
}

typedef StrumLineData = {
	var charName:String;
	var charPos:CharacterPosition;
	var charVisible:Bool;

	var strumPos:Array<Float>;
	var strumAlpha:Float;
	var strumScale:Float;

	var scrollSpeed:Float;
	var cpu:Bool;
	var notes:Array<NoteData>;

	var ?vocalsSuffix:String;
}

enum abstract CharacterPosition(Int) from Int to Int {
	var OPPONENT = 0;
	var PLAYER = 1;
	var ADDITIONAL = 2;
}

typedef NoteData = {
	var t:Float;
	var s:Int;
	var k:Int;
	var l:Float;
}
