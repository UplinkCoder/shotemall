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

   Empty = ' ',
   Wall = '#',

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
  int x, y;
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
    int player_count; /// 0 means game has not started yet
    int[] player_points; /// invaraint: length == player_count
    Direction[] bulletDirections; /// invariant: length == player_count

    Tile[y_dim][x_dim] tiles;
}

pragma(msg, "x_dim: ", GameState.init.tiles.length, " y_dim: ", GameState.init.tiles[0].length);


/// returns the player number
/// 0 if not a home position
int isHome(int x, int y)
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
    foreach(y;0 .. y_dim)
    {
        foreach(x;0 .. x_dim)
        {
            if (x == 0 || y == 0 || y == (y_dim - 1) || x == (x_dim - 1))
            {
                if (auto h = isHome(x, y))
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

Position PlayerPosition(GameState* game_state, int player)
{
    assert(player > 0 && player <= 8);
    return Position.init;
}

void AddPlayers(GameState* game_state, int player_count)
{

}

void main()
{
    GameState game_state;
//    writeln(MapToString(&map));
    AddDefaultTiles(&game_state);
    writeln(MapToString(&game_state));
}

