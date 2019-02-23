module shotemall.shotemall;

enum Direction
{
    Invalid,

    Up,
    Down,
    Left,
    Right,
}

enum Tile
{
   Invalid = '_',

   Empty      = ' ',
   Wall	      = '#',

   PlayerBody  = '0',
   PlayerBody1 = '1',
   PlayerBody2 = '2',
   PlayerBody3 = '3',
   PlayerBody4 = '4',
   PlayerBody5 = '5',
   PlayerBody6 = '6',
   PlayerBody7 = '7',
   PlayerBody8 = '8',

   PlayerGun   = '+',
   PlayerGun1  = 's',
   PlayerGun2  = 't',
   PlayerGun3  = 'v',
   PlayerGun4  = 'u',
   PlayerGun5  = 'w',
   PlayerGun6  = 'y',
   PlayerGun7  = 'x',
   PlayerGun8  = 'z',

   Bullet      = '.',
   Bullet1     = 'a',
   Bullet2     = 'b',
   Bullet3     = 'c',
   Bullet4     = 'd',
   Bullet5     = 'e',
   Bullet6     = 'f',
   Bullet7     = 'g',
   Bullet8     = 'h',

   Home        = 'H',
   Home1       = 'I',
   Home2       = 'J',
   Home3       = 'K',
   Home4       = 'L',
   Home5       = 'M',
   Home6       = 'N',
   Home7       = 'O',
   Home8       = 'P',

   Essence     = '$',
}

struct Position
{
  int x = int.min;
  int y = int.min;

  Position opBinary(string op : "+")(Position p2)
  {
     return Position(this.x + p2.x, this.y + p2.y);
  }

  Position opBinary(string op : "-")(Position p2)
  {
     return Position(this.x - p2.x, this.y - p2.y);
  }
}

enum Action
{
  Invalid,

  Nothing,
  TurnLeft,
  TurnRight,
  Forward,
  Backward,

  Shot
}

struct Home
{
  int x; /// x position
  int y; /// y position
  int p; /// player number
}

static immutable Home[] homes = 
[
    Home(12, 0, 8),
    Home(22, 0, 6),
    Home(17, 23, 5),
    Home(27, 23, 7),
    Home(0, 5, 1),
    Home(39, 5, 4),
    Home(0, 18, 3),
    Home(39, 18, 2),
];

// void computeNextAction(AIPlayer aip, DecisionRecord dr, )
/+
Original start pos:


Symetric Start pos diff:

5: [12, 23]
6: [27, 0]

You can either move or shoot. 
  - Shots are only possible if no shot of you is in flight.
You cannot push other players nor can you move through walls

Bullet is always 2-3 times faster than the player moves.
whenever bullets hit each other they are destroyed immediately
Bullets are stopped by walls and essence
Loosing essence means loosing one score point as long as score is positive.
+/


enum x_dim = 40;
enum y_dim = 24;

struct GameState
{
    int player_count = 0; /// 0 means game has not started yet
    int[] player_points; /// invaraint: length == player_count
    Direction[] bulletDirections; /// invariant: length == player_count

    Tile[y_dim][x_dim] tiles;

	auto tileForeach()
	{
		struct ForeachInner
		{
			GameState* game_state;

			this(GameState* game_state)
			{
				this.game_state = game_state;
			}

			int opApply(int delegate(int x, int y, ref Tile tile) dg)
			{
                int rv;
				foreach(x; 0 .. x_dim)
				{
					foreach(y; 0 .. y_dim)
					{
						rv = dg(x, y, game_state.tiles[x][y]);
					}
				}
                return rv;
			}
		}

		return ForeachInner(&this);
	}
}

pragma(msg, "x_dim: ", GameState.init.tiles.length, " y_dim: ", GameState.init.tiles[0].length);


/// returns the player number
/// 0 if not a home position
int isPlayerHome(int x, int y)
{
    int result = 0; 

    foreach(home;homes)
    {
        if (home.x == x && home.y == y)
        {
            result = home.p;
        }
    }

    return result;
}

Action[] PossibleActions(GameState* game_state, int player)
{
    assert (player > 0 && player <= 8);
    if (game_state.player_count < player) return [];
    assert (0);
}

void AddDefaultTiles(GameState* game_state)
{
    int i;
    assert(game_state.player_count == 0, 
        "You cannot add the default tiles to a running game"
    );

    foreach(y;0 .. y_dim)
    {
        foreach(x;0 .. x_dim)
        {
            if (x == 0 || y == 0 || y == (y_dim - 1) || x == (x_dim - 1))
            {
                if (auto h = isPlayerHome(x, y))
                {
                    game_state.tiles[x][y] = cast(Tile)(Tile.Home + h);
                }
                else
                {
                    game_state.tiles[x][y] = Tile.Wall;
                }
            }
            else
            {
                game_state.tiles[x][y] = Tile.Empty;
            }
        }
    }
}

string MapToString(GameState* game_state)
{
    char[] map_rep;
    map_rep.length = (x_dim * y_dim) + y_dim;
    int i;
    foreach(y;0 .. y_dim)
    {
        foreach(x;0 .. x_dim)
        {
            map_rep[i++] = game_state.tiles[x][y];
        }
        map_rep[i++] = '\n';
    }
    return cast(string) map_rep;
}

import std.stdio;

Position PositionOf(GameState* game_state, Tile tileType)
{
    Position position;

	foreach(x, y, tile; game_state.tileForeach)
	{
        if (tile == tileType)
        {
            position.x = x;
            position.y = y;
        }
	}

    return position;
}

bool isFree(GameState* game_state, Position p)
{
    return game_state.tiles[p.x][p.y] == Tile.Empty;
}

bool MoveForward(GameState* game_state, int player)
{
    Tile body_tile = cast(Tile)(Tile.PlayerBody1 + (player - 1));
    Tile gun_tile = cast(Tile)(Tile.PlayerGun1 + (player - 1));
    auto body_p = PositionOf(game_state, body_tile);
    auto gun_p = PositionOf(game_state, gun_tile);
    auto movement_vector = gun_p - body_p; // the movement vector is the vector from body to gun

    bool result = false;

    // TODO solve for movement properly! (2 step movement resolve)
    // TODO syncroize with other players
    if (isFree(game_state, gun_p + movement_vector))
    {
        result = AtomicMove(game_state, gun_p, gun_p + movement_vector);
        if (result) AtomicMove(game_state, body_p, gun_p); 
        // technically we could me non-atomically here (if we checked the previous atomic_move)
    }
    return result;
}

bool MoveBackward(GameState* game_state, int player)
{
    Tile body_tile = cast(Tile)(Tile.PlayerBody1 + (player - 1));
    Tile gun_tile = cast(Tile)(Tile.PlayerGun1 + (player - 1));
    auto body_p = PositionOf(game_state, body_tile);
    auto gun_p = PositionOf(game_state, gun_tile);
    auto movement_vector = body_p - gun_p; // the movement vector is the vector from gun to body

    bool result = false;

    // TODO solve for movement properly! (2 step movement resolve)
    // TODO syncroize with other players
    if (isFree(game_state, gun_p + movement_vector))
    {
        result = AtomicMove(game_state, body_p, body_p + movement_vector);
        if (result) AtomicMove(game_state, gun_p, body_p);
        // technically we could me non-atomically here (if we checked the previous atomic_move)
    }

    return result;
}

/// returns false if move fails
bool AtomicMove(GameState* game_state, Position from, Position to)
{
    bool result = false;

    if (isFree(game_state, to) && !isFree(game_state, from))
    {
        game_state.tiles[to.x][to.y] = game_state.tiles[from.x][from.y];
        game_state.tiles[from.x][from.y] = Tile.Empty;

        result = true;
    }

    return result;
}

pragma(msg,
(() {
    GameState game_state;
    AddDefaultTiles(&game_state);
    game_state.tiles[12][12] = Tile.PlayerBody1;
    game_state.tiles[12][13] = Tile.PlayerGun1;
    Position p;
    assert(p.x == int.min && p.y == int.min);
    p = PositionOf(&game_state, Tile.PlayerBody1);
    assert(p.x == 12 && p.y == 12);
    p = PositionOf(&game_state, Tile.PlayerGun1);
    assert(p.x == 12 && p.y == 13);
    auto BeforeMove = MapToString(&game_state);
    foreach(_; 0 .. 12) MoveForward(&game_state, 1);
    auto AfterMove = MapToString(&game_state); 
    return  BeforeMove ~ "\n   Forward Move (p1) 12 steps: \n" ~ AfterMove;
} ())
);

bool canMoveForward(int player)
{
    return false;
}

void StartGame(GameState* game_state, int player_count)
{
    assert(game_state.player_count == 0,
        "You are trying to start a game which seems to be still running"
    );
}

void main()
{
    GameState game_state;
//    writeln(MapToString(&map));
    AddDefaultTiles(&game_state);
    // TODO Select a proper map and Add the tiles to the game_state

    StartGame(&game_state, 1);
    foreach(i; 0 .. 64)
    {
        //RandomMove(&game_state, 1);
    }   
    writeln(MapToString(&game_state));
}
