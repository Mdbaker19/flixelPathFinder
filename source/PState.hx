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

class PState extends FlxState
{

    var speed: Float = 220;
	var ground: FlxSprite;
	var debugSprites: FlxTypedGroup<FlxSprite>;
	
    var p: FlxSprite;
    var pPathPoint: FlxPoint;
	var pCanGoUp: Bool;
	var pt: FlxSprite;

	var tiles: FlxTilemap;
	var pathTiles: FlxTilemap;
	var map:FlxOgmo3Loader;

    var mySpritesOnMap: FlxTypedGroup<FlxSprite>;

	override public function create()
	{
		super.create();

		ground = new FlxSprite(0, FlxG.height);
		ground.makeGraphic(FlxG.width, 1);
		ground.immovable = true;
		ground.visible = false;
		add(ground);

		debugSprites = new FlxTypedGroup<FlxSprite>();
        mySpritesOnMap = new FlxTypedGroup<FlxSprite>();

		p = new FlxSprite();
        pPathPoint = new FlxPoint();
		p.makeGraphic(24, 59, FlxColor.RED);

		pt = new FlxSprite();
		// pt.acceleration.y = 50;
		// pt.maxVelocity.y = 200;
		pt.makeGraphic(36, 10, FlxColor.WHITE);
		pt.visible = false;

		FlxG.debugger.drawDebug = true;

	}

    function addP(): Void {
        #if FLX_DEBUG
		add(debugSprites);
        #end
        add(mySpritesOnMap);
        add(pt);
        add(p);
		map.loadEntities(placeEntities, "entity");
    }

	override public function update(dt:Float)
	{
		super.update(dt);
		FlxG.collide(p, pathTiles);
		FlxG.collide(pt, pathTiles);
		FlxG.collide(pt, ground);

		p.y = FlxMath.bound(p.y, 0, FlxG.height - p.height);

		if (handleMove(dt)) {
            clearPath();
        }

		if (FlxG.mouse.justReleased) {
			pt.x = FlxG.mouse.x;
			var clickedPoint: FlxPoint = pathTiles.getTilePosAt(FlxG.mouse.x, FlxG.mouse.y);
			var targetPoint: FlxPoint = findTheGroudBelow(clickedPoint);
			// trace('CLICKED POINT: ${clickedPoint} RETURNED POINT: ${targetPoint}');
			pt.setPosition(targetPoint.x - pt.width / 2, targetPoint.y + (pathTiles.tileHeight / 2) - pt.height - 2);
			pt.visible = true;
			var path: FlxPath = new FlxPath();
            pPathPoint = new FlxPoint(
                p.getMidpoint().x,
                p.y + (p.height * 0.8)
            );
            // pPathPoint = p.getMidpoint();
			var paths: Array<FlxPoint> = pathTiles.findPath(pPathPoint, targetPoint, LINE, NONE);
			if (paths != null) {
				path.nodes = paths;
				p.path = path;
				p.path.start(paths, speed);
			}
		}

		if (FlxG.overlap(p, pt, null, verifyOnTarget)) {
			clearPath();
		}
	}

    function verifyOnTarget(p: FlxSprite, pt: FlxSprite): Bool {
        if (p.y + p.height + 1 > pt.y + pt.height) return true;
        return false;
    }

    function clearPath(): Void {
        pt.visible = false;
        p.path = null;
        debugSprites.clear();
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
			if (tileData != null && tileData.solid && tileData.index != 3 || tileData.index == 4) {
				// trace('SOLID: ${tileData.solid} AT X: ${tileData.x} Y: ${tileData.y}');
                // Is rope - allow move to top of rope
				return new FlxPoint(point.x + pt.width / 2, ySpot - (p.height / 2));
			}
		}
		// must have over shot
		return new FlxPoint(point.x + pt.width / 2, FlxG.height - (p.height / 2));
	}


    // place my sprites on top
    // need to know:
    // tile width
    // width of my sprite - i.e the rope
    //.       center it out width wise flag and always placed at top height spot
    // requires: all my sprites for map to be minimum, same height.
    // maybe take a widthDiffs array? [0: 0] in this case and [4: 12] or something if rope at 
    // tile 4 was 12pixels thinner requiring a 6px offset in both dirs
    function placeMyStuff(): Void {
        for (c in 0...pathTiles.heightInTiles) {
            for (r in 0...pathTiles.widthInTiles) {
                var tileData: FlxTile = pathTiles.getTileData(r, c);
                if (tileData != null) {
                    trace(tileData.index);
                    if (tileData.index == 0) {
                        // getcolumnpos and rowpos is just way tf off
                        var ySpot: Float = c * tileData.height;
                        var xSpot: Float = r * tileData.width;
                        var s: FlxSprite = new FlxSprite(xSpot, ySpot);
                        s.makeGraphic(Std.int(tileData.width), Std.int(tileData.height), FlxColor.CYAN);
                        mySpritesOnMap.add(s);
                    }
                     else if (tileData.index == 4) {
                        // getcolumnpos and rowpos is just way tf off
                        var ySpot: Float = c * tileData.height;
                        var xSpot: Float = r * tileData.width;
                        var s: FlxSprite = new FlxSprite(xSpot + 6, ySpot);
                        s.makeGraphic(Std.int(tileData.width - 12), Std.int(tileData.height), 0xF67AC80C);
                        mySpritesOnMap.add(s);
                    }
                } else {
                    // I do not understand why this hits 'sometimes'
                    trace('Null at C${c} | R${r}');
                }
            }
        }
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

	function handleMove(dt: Float): Bool {

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
			p.velocity.setPolarDegrees(speed, newAngle);
            return true;
		}
		
        p.velocity.setPolarDegrees(0, 0);
        return false;
	}

}
