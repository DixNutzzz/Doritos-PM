package game.data.song;

typedef SongData = {
	var meta:SongMeta;
	var playData:SongPlayData;

	var needsVoices:Bool;
	var events:Array<EventData>;
	var notes:Array<NoteData>;

	var isDoritos:Bool;
}

typedef SongMeta = {
	var song:String;
	var bpm:Float;
	var beatsPerMeasure:Float;
	var stepsPerBeat:Float;
}

typedef SongPlayData = {
	var stage:String;
	var scrollSpeed:Float;
	var noteKinds:Array<String>;
	var strumlines:Array<StrumlineData>;
}

typedef StrumlineData = {
	var cpu:Bool;
	var char:StrumlineCharacter;
	var pos:Array<Float>;
	var alpha:Float;
	var scale:Float;
	var vocalsSuffix:String;
}

typedef StrumlineCharacter = {
	var name:String;
	var pos:Int;
}

typedef EventData = {
	/** time **/
	var t:Float;
	/** kind **/
	var k:String;
	/** params **/
	var p:Array<Dynamic>;
}

typedef NoteData = {
	/** time **/
	var t:Float;
	/** length **/
	var l:Float;
	/** kind **/
	var k:Int;
	/** player **/
	var p:Int;
	/** strum **/
	var s:Int;
}
