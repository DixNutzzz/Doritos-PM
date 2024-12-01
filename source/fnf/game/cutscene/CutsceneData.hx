package fnf.game.cutscene;

import fnf.backend.data.AnimData;

typedef CutsceneData = {
	var tps:Float;
	var camera:{
		var follow:{
			var x:Float;
			var y:Float;
		}
		var zoom:Float;
		var angle:Float;
	}
	var zoom:Float;
	var actors:Array<ActorData>;
}

typedef ActorData = {
	var atlas:{
		var key:String;
		var type:AtlasType;
	}
	var animations:Array<AnimData>;
	var position:{
		var x:Float;
		var y:Float;
	}
	var scale:{
		var x:Float;
		var y:Float;
	}
	var scrollFactor:{
		var x:Float;
		var y:Float;
	}
	var alpha:Float;
	var angle:Float;
}
