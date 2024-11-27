package fnf.backend.beatmap;

import haxe.io.Path;
import openfl.Assets;
import flixel.util.FlxColor;
import haxe.xml.Access;

using StringTools;

typedef EventData = {
	var description:String;
	var params:Array<EventParamData>;
}

typedef EventParamData = {
	var name:String;
	var type:EventParamType;
	var value:Dynamic;
}

enum EventParamType {
	BOOLEAN;
	INTEGER;
	FLOAT;
	STRING;
	COLOR;
}

class Events {
	public static var list:Array<EventData> = [];

	public static function reloadList() {
		var paths = Assets.list(TEXT).filter(asset -> Path.directory(asset) == 'assets/events' && asset.endsWith('.xml'));
		for (path in paths) {
			var event = parseXml(Assets.getText(path));
			if (event != null) list.push(event);
		}
	}

	// TODO: rewrite
	public static function parseXml(s:String):EventData {
		var xml = new Access(Xml.parse(s).firstElement());
		if (xml.name != 'event') {
			Logger.warn('Event XML parsing: ${xml.name} should be event');
			return null;
		}

		var result:EventData = {
			description: xml.hasNode.description ? xml.node.description.innerHTML.trim() : '',
			params: []
		}

		for (node in xml.nodes.param) {
			var skip = false;
			if (!node.has.name) {
				Logger.warn('Event XML parsing: param should have attribute name');
				skip = true;
			}
			if (!node.has.type) {
				Logger.warn('Event XML parsing: param should have attribute type');
				skip = true;
			}
			if (skip) continue;

			var type:EventParamType = switch node.att.type {
				case 'b' | 'bool' | 'boolean': BOOLEAN;
				case 'i' | 'int' | 'integer': INTEGER;
				case 'f' | 'float': FLOAT;
				case 's' | 'string' | 'text': STRING;
				case 'c' | 'color' | 'colour': COLOR;
				default: null;
			}

			if (type == null) {
				Logger.warn('Event XML parsing: unknown param type ${node.att.type}');
				continue;
			}

			result.params.push({
				name: node.att.name.trim(),
				type: type,
				value: node.has.value ? switch type {
					case BOOLEAN: node.att.value.toLowerCase().trim() == 'true';
					case INTEGER: Std.parseInt(node.att.value);
					case FLOAT: Std.parseFloat(node.att.value);
					case STRING: node.att.value.trim();
					case COLOR: FlxColor.fromString(node.att.value.trim());
				} : null
			});
		}

		return result;
	}
}
