// package;

// import flixel.tile.FlxTile;
// import flixel.tile.FlxTilemap;
// import flixel.util.FlxDirection;
// import flixel.math.FlxPoint;

// enum FlxRayEntry
// {
// 	/** The ray entered the tile on the given edge */
// 	EDGE(dir:FlxDirection);
	
// 	/** The ray started in the tile */
// 	START;
// }

// enum FlxRayResult
// {
// 	/** The ray reached a stopping tile */
// 	STOPPED(mapIndex:Int, x:Float, y:Float, entry:FlxRayEntry);
	
// 	/** The ray reached the end without being stopped */
// 	END;
// }

// class Util {
//     public function findInRay
// 		(map: FlxTilemap, start:FlxPoint, end:FlxPoint, func:(index:Int, tile:Null<FlxTile>, entry:FlxRayEntry)->Bool):FlxRayResult
// 	{
// 		// trim the line to the parts inside the map
// 		final trimmedStart = map.calcRayEntry(start, end);
// 		final trimmedEnd = map.calcRayExit(start, end);
		
// 		start.putWeak();
// 		end.putWeak();
		
// 		if (trimmedStart == null && trimmedEnd == null)
// 			return END;
		
// 		// Cache x/y in floats so we can put() them now
// 		final wasStartTrimmed = trimmedStart.x != start.x || trimmedStart.y != start.y;
// 		final startX = trimmedStart.x;
// 		final startY = trimmedStart.y;
// 		final endX = trimmedEnd.x;
// 		final endY = trimmedEnd.y;
// 		trimmedStart.put();
// 		trimmedEnd.put();
		
// 		final startIndex = map.getMapIndexAt(startX, startY);
// 		final endIndex = map.getMapIndexAt(endX, endY);
// 		final startTileX = map.getColumn(startIndex);
// 		final startTileY = map.getRow(startIndex);
// 		final endTileX = map.getColumn(endIndex);
// 		final endTileY = map.getRow(endIndex);
// 		final dirY = start.y < end.y ? FlxDirection.UP : FlxDirection.DOWN;
		
// 		// handle vertical line (infinite slope), first
// 		if (start.x == end.x)
// 		{
// 			final entry = wasStartTrimmed ? EDGE(dirY) : START;
// 			final resultIndex = findIndexInColumnWithEntry(map, startTileX, startTileY, endTileY, func, entry);
// 			if (resultIndex != -1)
// 			{
// 				final resultY = map.getRowPos(map.getRow(resultIndex) + (start.y > end.y ? 1 : 0));
// 				final colEntry = map.getRow(resultIndex) == startTileY ? entry : EDGE(dirY);
// 				return STOPPED(resultIndex, start.x, resultY, colEntry);
// 			}
			
// 			return END;
// 		}
		
// 		// Use y = mx + b formula
// 		final m = (start.y - end.y) / (start.x - end.x);
// 		// y - mx = b
// 		final b = start.y - m * start.x;
		
// 		final movesRight = start.x < end.x;
// 		final inc = movesRight ? 1 : -1;
// 		final offset = movesRight ? 1 : 0;
// 		var colEntry = wasStartTrimmed ? EDGE(movesRight ? LEFT : RIGHT) : START;
// 		var lastTileY = startTileY;
		
// 		for (tileX in startTileX.iter(endTileX))
// 		{
// 			final xPos = getColumnPos(tileX + offset);
// 			final yPos = ambiClamp(m * getColumnPos(tileX + offset) + b, startY, endY);
// 			final tileY = getRowAt(yPos);
// 			final resultIndex = findIndexInColumnWithEntry(tileX, lastTileY, tileY, func, colEntry);
// 			if (resultIndex != -1)
// 			{
// 				final endY = getRow(resultIndex);
// 				final tileEntry = endY == lastTileY ? colEntry : EDGE(dirY);
// 				return calcRayResult(resultIndex, tileEntry, m, b, start);
// 			}
			
// 			colEntry = EDGE(movesRight ? LEFT : RIGHT);
// 			lastTileY = tileY;
// 		}
		
// 		return END;
// 	}

//     function findIndexInColumnWithEntry
// 		(map: FlxTilemap, column, startRow, endRow, func:(index:Int, tile:Null<FlxTile>, entry:FlxRayEntry) -> Bool, entry:FlxRayEntry)
// 	{
// 		final startI = map.getMapIndex(column, startRow);
// 		final edge = EDGE(startRow < endRow ? UP : DOWN);
		
// 		return findIndexInColumn(map, column, startRow, endRow, function(i, t)
// 		{
// 			return func(i, t, i == startI ? entry : edge);
// 		});
// 	}

//     public function findIndexInColumn(map: FlxTilemap, column:Int, startRow:Int, endRow:Int, func:(index:Int, tile:Null<FlxTile>)->Bool):Int {
		
// 		if (startRow < 0)
// 			startRow = 0;
// 		else if (startRow > map.heightInTiles - 1)
// 			startRow = map.heightInTiles - 1;
			
// 		if (endRow < 0)
// 			endRow = 0;
// 		else if (endRow > map.heightInTiles - 1)
// 			endRow = map.heightInTiles - 1;
			
// 		for (row in startRow.iter(endRow))
// 		{
// 			final index = map.getMapIndex(column, row);
// 			if (index == -1)
// 				throw 'Unexpected -1 map index for column: $column row: $row';
			
// 			final tile = map.getTileData(index, true);
// 			if (func(index, tile))
// 				return index;
// 		}
		
// 		return -1;
// 	}

    
// }

// private class AmbiIntIterator 
// {
// 	final start:Int;
// 	final iterator:IntIterator;
// 	final step:Int;
	
// 	inline public function new(start:Int, end:Int, inclusive = true)
// 	{
// 		this.start = start;
// 		this.step = start < end ? 1 : -1;
// 		final dis = (end - start) * step + (inclusive ? 1 : 0);
// 		iterator = (0... dis);
// 	}
	
// 	inline public function hasNext()
// 	{
// 		return iterator.hasNext();
// 	}
	
// 	inline public function next()
// 	{
// 		return start + iterator.next() * step;
// 	}
	
// 	inline static public function iter(start:Int, end:Int, inclusive = true)
// 	{
// 		return new AmbiIntIterator(start, end, inclusive);
// 	}
// }