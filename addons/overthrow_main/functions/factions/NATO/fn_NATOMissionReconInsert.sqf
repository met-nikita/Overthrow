/*
	Inserts a recon team to _knownPos to do _objective
*/

params ["_knownPos", "_objective"];

private _posTarget = _knownPos;
private _close = nil;
private _dist = 2000;
private _closest = "";
private _abandoned = server getVariable["NATOabandoned",[]];
{
	_pos = _x select 0;
	_name = _x select 1;
	if(([_pos,_knownPos] call OT_fnc_regionIsConnected) && !(_name in _abandoned)) then {
		_d = (_pos distance _knownPos);
		if(_d < _dist) then {
			_dist = _d;
			_close = _pos;
			_closest = _name;
		};
	};
}forEach(OT_NATOobjectives);
_isAir = false;
if(isNil "_close") then {
	_isAir = true;
	{
		_x params ["_obpos","_name","_pri"];
		if !(_name in _abandoned) exitWith {
			_close = _obpos;
		};
	}forEach(OT_airportData call BIS_fnc_arrayShuffle);
};
// Group may not be moved into a vehicle, so it also needs space to spawn
_start = [_close,50,200, 1, 0, 0, 0] call BIS_fnc_findSafePos;
_group = [_start, west, OT_NATO_Group_Recon] call BIS_fnc_spawnGroup;

// These are special forces, they are much better than regular guys
// Randomskill macro to add some variance to units
#define RANDOMSKILL (random [0.75,0.8,0.85])
{
	_x setSkill ["courage", RANDOMSKILL];
	_x setSkill ["spotDistance", RANDOMSKILL];
	_x setSkill ["spotTime", RANDOMSKILL];
	_x setSkill ["commanding", RANDOMSKILL];
	_x setSkill ["reloadSpeed", RANDOMSKILL];
} forEach (units _group);
_group allowFleeing 0.33; // Make them less likely to flee

sleep 0.5;

_dir = (_close getDir _posTarget);

if(_isAir) then {

	//Determine direction to attack from (preferrably away from water)
	_attackdir = random 360;
	if(surfaceIsWater (_posTarget getPos [150,_attackDir])) then {
		_attackdir = _attackdir + 180;
		if(_attackdir > 359) then {_attackdir = _attackdir - 359};
		if(surfaceIsWater (_posTarget getPos [150,_attackDir])) then {
			_attackdir = _attackdir + 90;
			if(_attackdir > 359) then {_attackdir = _attackdir - 359};
			if(surfaceIsWater (_posTarget getPos [150,_attackDir])) then {
				_attackdir = _attackdir + 180;
				if(_attackdir > 359) then {_attackdir = _attackdir - 359};
			};
		};
	};
	_attackdir = _attackdir - 45;
	_ao = _posTarget getPos [(350 + random 150), (_attackdir + random 90)];
	_tgroup = createGroup blufor;

	_spawnpos = _close findEmptyPosition [15,100,OT_NATO_Vehicle_AirTransport_Small];
    if (count _spawnpos == 0) then {_spawnpos = _close findEmptyPosition [8,100,OT_NATO_Vehicle_AirTransport_Small]};
	_veh =  OT_NATO_Vehicle_AirTransport_Small createVehicle _spawnpos;
	_veh setDir _dir;
	_tgroup addVehicle _veh;



	createVehicleCrew _veh;
	{
		[_x] joinSilent _tgroup;
		_x setVariable ["garrison","HQ",false];
		_x setVariable ["NOAI",true,false];
	}forEach(crew _veh);

	{
		_x moveInCargo _veh;
		_x setVariable ["garrison","HQ",false];
	}forEach(units _group);

	sleep 2;

	_moveto = _close getPos [500, _dir];
	_wp = _tgroup addWaypoint [_moveto,0];
	_wp setWaypointType "MOVE";
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointSpeed "FULL";
	_wp setWaypointCompletionRadius 150;
	_wp setWaypointStatements ["true","(vehicle this) flyInHeight 200;"];

	_wp = _tgroup addWaypoint [_ao,0];
	_wp setWaypointType "MOVE";
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointStatements ["true","(vehicle this) AnimateDoor ['Door_rear_source', 1, false];"];
	_wp setWaypointCompletionRadius 50;
	_wp setWaypointSpeed "FULL";

	_wp = _tgroup addWaypoint [_ao,0];
	_wp setWaypointType "SCRIPTED";
	_wp setWaypointStatements ["true","[vehicle this,75] spawn OT_fnc_parachuteAll"];
	_wp setWaypointTimeout [10,10,10];

	_wp = _tgroup addWaypoint [_ao,0];
	_wp setWaypointType "SCRIPTED";
	_wp setWaypointStatements ["true","(vehicle this) AnimateDoor ['Door_rear_source', 0, false];"];
	_wp setWaypointTimeout [15,15,15];

	_moveto = _close getPos [200, _dir];

	_wp = _tgroup addWaypoint [_moveto,0];
	_wp setWaypointType "LOITER";
	_wp setWaypointBehaviour "CARELESS";
	_wp setWaypointSpeed "FULL";
	_wp setWaypointCompletionRadius 100;

	_wp = _tgroup addWaypoint [_moveto,0];
	_wp setWaypointType "SCRIPTED";
	_wp setWaypointStatements ["true","[vehicle this] call OT_fnc_cleanup"];

	{
		_x addCuratorEditableObjects [units _tgroup,true];
	} forEach allCurators;
};
{
	_x addCuratorEditableObjects [units _group,true];
} forEach allCurators;
sleep 2;

//This squad operates in stealth mode, therefore does not respond to calls for help from other units
{
	_x setVariable ["VCOM_NOPATHING_Unit",true,false];
	_x setVariable ["OT_targetPos",_knownPos,true];
}forEach(units _group);

_wp = _group addWaypoint [_knownPos,0];
_wp setWaypointType "MOVE";
_wp setWaypointBehaviour "STEALTH";
_wp setWaypointSpeed "FULL";
_wp setWaypointStatements ["true", _objective];