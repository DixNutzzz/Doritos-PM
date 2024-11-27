package fnf.backend.beatmap;

typedef BeatmapData = {
	var song:String;
	var bpm:Float;
	var needsVoices:Bool;

	var playerChar:String;
	var opponentChar:String;
	var ?additionalChar:String;
	var stage:String;

	var scrollSpeed:Float;

	var events: {
		var kinds:Array<String>;
		var params:Array<Dynamic>;
		var list:Array<SongEvent>;
	}
	var notes: {
		var kinds:Array<String>;
		var list:Array<SongNote>;
	}
}

typedef SongEvent = {
	var k:Int;
	var p:Array<Int>;
}

typedef SongNote = {
	var t:Float;
	var l:Float;
	var s:Int;
	var p:Int;
	var k:Int;
}
