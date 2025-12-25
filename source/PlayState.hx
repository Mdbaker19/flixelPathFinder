package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tile.FlxTile;
import flixel.math.FlxPoint;
import flixel.path.FlxPath;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{

	var ground: FlxSprite;
	var debugSprites: FlxTypedGroup<FlxSprite>;
	var p: FlxSprite;
	var pCanGoUp: Bool;
	var pt: FlxSprite;
	var tiles: FlxTilemap;
	var pathTiles: FlxTilemap;
	var map:FlxOgmo3Loader;

	override public function create()
	{
		super.create();

		ground = new FlxSprite(0, FlxG.height);
		ground.makeGraphic(FlxG.width, 1);
		ground.immovable = true;
		ground.visible = false;
		add(ground);

		map = new FlxOgmo3Loader('assets/data/path.ogmo', 'assets/data/path.json');
		pathTiles = map.loadTilemap('assets/images/pathTiles.png', "path");

		pathTiles.follow();
		pathTiles.setTileProperties(0, ANY);
		pathTiles.setTileProperties(1, NONE);
		pathTiles.setTileProperties(2, ANY);

		trace(pathTiles.heightInTiles);

		add(pathTiles);

		debugSprites = new FlxTypedGroup<FlxSprite>();
		add(debugSprites);

		p = new FlxSprite();
		p.makeGraphic(38, 58, FlxColor.RED);

		pt = new FlxSprite();
		// pt.acceleration.y = 50;
		// pt.maxVelocity.y = 200;
		pt.makeGraphic(36, 10, FlxColor.WHITE);
		pt.visible = false;
		add(pt);

		add(p);

		map.loadEntities(placeEntities, "entity");

		FlxG.debugger.drawDebug = true;

	}

	override public function update(dt:Float)
	{
		super.update(dt);
		FlxG.collide(p, pathTiles);
		FlxG.collide(pt, pathTiles);
		FlxG.collide(pt, ground);

		p.y = FlxMath.bound(p.y, 0, FlxG.height - p.height);

		handleMove(dt);

		if (FlxG.mouse.justReleased) {
			pt.x = FlxG.mouse.x;
			var clickedPoint: FlxPoint = pathTiles.getTilePosAt(FlxG.mouse.x, FlxG.mouse.y);
			var targetPoint: FlxPoint = findTheGroudBelow(clickedPoint);
			// trace('CLICKED POINT: ${clickedPoint} RETURNED POINT: ${targetPoint}');
			pt.setPosition(targetPoint.x - pt.width / 2, targetPoint.y);
			pt.visible = true;
			var path: FlxPath = new FlxPath();
			var paths: Array<FlxPoint> = pathTiles.findPath(p.getMidpoint(), targetPoint, LINE, NONE);
			if (paths != null) {
				path.nodes = paths;
				p.path = path;
				p.path.start();
			}
		}

		if (FlxG.overlap(p, pt)) {
			pt.visible = false;
		}
	}



	function findTheGroudBelow(point: FlxPoint): FlxPoint {
		var startIdx: Int = pathTiles.getRowAt(point.y);
		debugSprites.clear();
		// trace('CLIKED IN START ROW: ${startIdx}');
		for (i in startIdx...pathTiles.heightInTiles) {
			var ySpot: Float = i * pathTiles.tileHeight;
			// trace('CHECKING INDEX: ${i} AT: ${ySpot} FOR SOLID');
			var tileData: FlxTile = pathTiles.getTileDataAt(point.x, ySpot);
			debugSprites.add(debugSprite(point.x, ySpot));
			if (tileData != null && tileData.solid) {
				// trace('SOLID: ${tileData.solid} AT X: ${tileData.x} Y: ${tileData.y}');
				return new FlxPoint(point.x + pt.width / 2, ySpot - pt.height);
			}
		}
		// must have over shot
		return new FlxPoint(point.x + pt.width / 2, FlxG.height - pt.height);
	}

	function debugSprite(x: Float, y: Float): FlxSprite {
		var s: FlxSprite = new FlxSprite(x, y);
		s.makeGraphic(40, 60, FlxColor.WHITE);
		s.alpha = 0.6;
		return s;
	}

	function placeEntities(entity:EntityData)
	{
		if (entity.name == "player")
		{
			p.setPosition(entity.x, entity.y);
		}
	}

	function handleMove(dt: Float): Void {

		var up:       Bool = false;
        var down:     Bool = false;
		var left:     Bool = false;
        var right:    Bool = false;

        up = FlxG.keys.anyPressed([UP, W]);
        down = FlxG.keys.anyPressed([DOWN, S]);
        left = FlxG.keys.anyPressed([LEFT, A]);
        right = FlxG.keys.anyPressed([RIGHT, D]);

		if (up || down || left || right)
		{
			var newAngle:Float = 0;
			if (up)
			{
				newAngle = -90;
				if (left)
					newAngle -= 45;
				else if (right)
					newAngle += 45;
			}
			else if (down)
			{
				newAngle = 90;
				if (left)
					newAngle += 45;
				else if (right)
					newAngle -= 45;
			}
			else if (left)
			{
				newAngle = 180;
			}
			else if (right)
			{
				newAngle = 0;
			}

			// determine our velocity based on angle and speed
			p.velocity.setPolarDegrees(120, newAngle);
		}
		else {
			p.velocity.setPolarDegrees(0, 0);
		}
	}

}
