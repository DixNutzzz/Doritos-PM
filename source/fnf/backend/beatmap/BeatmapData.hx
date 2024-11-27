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
	var strumPos:Array<Float>;
	var notes:Array<NoteData>;

	var charVisible:Bool;
	var strumVisible:Bool;
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
