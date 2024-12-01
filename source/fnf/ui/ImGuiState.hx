package fnf.ui;

import haxe.io.Bytes;
import flixel.FlxG;
import imgui.ImGui;

class ImGuiState extends MusicBeatState {
	static var io:ImGuiIO;

	override function create() {
		io = ImGui.getIO();
		io.displaySize = ImVec2.create(FlxG.width, FlxG.height);

		var atlas = cpp.Pointer.fromStar(io.fonts).ref;
		var width = 0, height = 0;
		var pixels = null;

		atlas.getTexDataAsRGBA32(pixels, width, height);

		trace(pixels);

		super.create();
	}
}
