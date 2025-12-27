package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;

class PlayState3 extends PState
{

	override public function create()
	{
		super.create();

		map = new FlxOgmo3Loader('assets/data/path.ogmo', 'assets/data/path2.json');
		pathTiles = map.loadTilemap('assets/images/fullNavTiles.png', "full");

		pathTiles.follow();
		pathTiles.setTileProperties(0, NONE);
		pathTiles.setTileProperties(1, ANY);
		pathTiles.setTileProperties(2, ANY);
		pathTiles.setTileProperties(3, ANY);
		pathTiles.setTileProperties(4, NONE);

        var bg: FlxSprite = new FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
        add(bg);

        placeMyStuff();

		addP();

	}

	override public function update(dt:Float)
	{
		super.update(dt);
	}

}
