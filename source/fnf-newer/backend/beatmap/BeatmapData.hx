package fnf.backend.beatmap;

typedef BeatmapData = {
	var song:String;
	var bpm:Float;
	var needsVoices:Bool;

	var stage:String;

	var scrollSpeed:Float;

	var eventKinds:Array<String>;
	var eventParams:Array<Dynamic>;
	var events:Array<EventData>;

	var noteKinds:Array<String>;
	var strumLines:Array<StrumLineData>;
}

typedef StrumLineData = {
	var char:String;
	var charPos:CharacterPosition;
	var charVisible:Bool;

	var strumPos:Array<Float>;
	var strumVisible:Bool;

	var notes:Array<NoteData>;
	var cpu:Bool;
}

enum abstract CharacterPosition(Int) from Int to Int {
	var OPPONENT = 0;
	var PLAYER = 1;
	var ADDITIONAL = 2;
}

typedef EventData = {
	var t:Float;
	var k:Int;
	var p:Array<Int>;
}

typedef NoteData = {
	var t:Float;
	var l:Float;
	var s:Int;
	var k:Int;
}
