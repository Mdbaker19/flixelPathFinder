package;

import flixel.addons.editors.ogmo.FlxOgmo3Loader;

class PlayState extends PState
{

	override public function create()
	{
		super.create();

		map = new FlxOgmo3Loader('assets/data/path.ogmo', 'assets/data/path.json');
		pathTiles = map.loadTilemap('assets/images/pathTiles.png', "path");

		pathTiles.follow();
		pathTiles.setTileProperties(0, ANY);
		pathTiles.setTileProperties(1, NONE);
		pathTiles.setTileProperties(2, ANY);

		trace(pathTiles.heightInTiles);

		add(pathTiles);

		addP();

	}

	override public function update(dt:Float)
	{
		super.update(dt);
	}

}
