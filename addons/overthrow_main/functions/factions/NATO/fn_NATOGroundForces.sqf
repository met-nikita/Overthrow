params ["_frompos","_ao","_attackpos","_byair",["_delay",0]];
if (_delay > 0) then {sleep _delay};
private _vehtype = selectRandom OT_NATO_Vehicle_Transport;
if(_byair) then {
	_vehtype = selectRandom OT_NATO_Vehicle_AirTransport;
};
private _squadtype = selectRandom OT_NATO_GroundForces;
private _spawnpos = _frompos;
private _group1 = [_spawnpos, west, _squadtype] call BIS_fnc_spawnGroup;
_group1 deleteGroupWhenEmpty true;
private _group2 = "";
private _tgroup = false;
if !(_byair) then {
	sleep 0.3;
	private _squadtype = selectRandom OT_NATO_GroundForces;
	_group2 = [_spawnpos, west, _squadtype] call BIS_fnc_spawnGroup;
	_group2 deleteGroupWhenEmpty true;
};
sleep 0.5;
private _allunits = [];
private _veh = false;
private _pos = false;

//Transport
private _tgroup = createGroup blufor;
private _dir = 0;

if(_byair) then {
	//find helipads
	private _helipads = (_frompos nearObjects ["Land_HelipadCircle_F", 400]) + (_frompos nearObjects ["Land_HelipadSquare_F", 400]);
	{
		//check if theres anything on it
		private _on = (ASLToAGL (getPosASL _x)) nearEntities [["Air", "LandVehicle", "Ship"], 15];
		if(_on isEqualTo []) exitWith {_pos = getPosASL _x;_dir = getDir _x};
	}forEach(_helipads);

	if !(_pos isEqualType []) then {
		_pos = _frompos findEmptyPosition [15,100,_vehtype];
		if (count _pos == 0) then {_pos = _frompos findEmptyPosition [8,100,_vehtype]};
		_dir = (_frompos getDir _ao);
	};
} else {
	_pos = _frompos findEmptyPosition [10,100,_vehtype];
	if (count _pos == 0) then {_pos = _frompos findEmptyPosition [0,100,_vehtype]};
	_dir = (_frompos getDir _ao);
};
_pos set [2,1]; // Set the altitude to 1 to hopefully avoid explosions
_veh = createVehicle [_vehtype, [0,0,1000+random 1000], [], 0, "CAN_COLLIDE"];
_veh setDir (_dir);
_veh setPosATL _pos;
_veh setVariable ["garrison","HQ",false];
clearWeaponCargoGlobal _veh;
clearMagazineCargoGlobal _veh;
clearItemCargoGlobal _veh;
clearBackpackCargoGlobal _veh;


_tgroup addVehicle _veh;
createVehicleCrew _veh;
{
	[_x] joinSilent _tgroup;
	_x setVariable ["garrison","HQ",false];
	_x setVariable ["NOAI",true,false];
}forEach(crew _veh);
_allunits = (units _tgroup);
{
	_x addCuratorEditableObjects [(units _tgroup) + [_veh],true];
} forEach allCurators;
sleep 1;

_tgroup deleteGroupWhenEmpty true;

{
	if(_tgroup isEqualType grpNull) then {
		_x moveInCargo _veh;
	};
	[_x] joinSilent _group1;
	_allunits pushBack _x;
	_x setVariable ["garrison","HQ",false];
	_x setVariable ["VCOM_NOPATHING_Unit",true,false];

	[_x] call OT_fnc_initMilitary;

}forEach(units _group1);

{
	_x addCuratorEditableObjects [units _group1,true];
} forEach allCurators;

spawner setVariable ["NATOattackforce",(spawner getVariable ["NATOattackforce",[]])+[_group1],false];

if !(_byair) then {
	{
		if(_tgroup isEqualType grpNull) then {
			_x moveInCargo _veh;
		};
		[_x] joinSilent _group2;
		_x setVariable ["VCOM_NOPATHING_Unit",true,false];
		_allunits pushBack _x;
		_x setVariable ["garrison","HQ",false];
		[_x] call OT_fnc_initMilitary;

	}forEach(units _group2);
	{
		_x addCuratorEditableObjects [units _group2,true];
	} forEach allCurators;
	spawner setVariable ["NATOattackforce",(spawner getVariable ["NATOattackforce",[]])+[_group2],false];
};

sleep 5;
if(_byair && _tgroup isEqualType grpNull) then {
	_wp = _tgroup addWaypoint [_frompos,0];
	_wp setWaypointType "MOVE";
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointSpeed "FULL";
	_wp setWaypointCompletionRadius 150;
	_wp setWaypointStatements ["true",format["(vehicle this) flyInHeight %1;",75+random 50]];

	_wp = _tgroup addWaypoint [_ao,0];
	_wp setWaypointType "MOVE";
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointStatements ["true","(vehicle this) AnimateDoor ['Door_rear_source', 1, false];"];
	_wp setWaypointCompletionRadius 50;
	_wp setWaypointSpeed "FULL";

	_wp = _tgroup addWaypoint [_ao,0];
	_wp setWaypointType "SCRIPTED";
	_wp setWaypointStatements ["true","[vehicle this,75] spawn OT_fnc_parachuteAll"];
	_wp setWaypointTimeout [5,5,5];

	_wp = _tgroup addWaypoint [_ao,0];
	_wp setWaypointType "SCRIPTED";
	_wp setWaypointBehaviour "CARELESS";
	_wp setWaypointStatements ["true","(vehicle this) AnimateDoor ['Door_rear_source', 0, false];"];
	_wp setWaypointTimeout [20,20,20];
}else{
	if(_tgroup isEqualType grpNull) then {
		_veh setDamage 0;
		_dir = (_attackpos getDir _frompos);
		_roads = _ao nearRoads 150;
		private _dropos = _ao;

		//Try to make sure drop position is on a bigger road
		{
			private _pos = ASLToAGL (getPosASL _x);
			if(isOnRoad _pos) exitWith {_dropos = _pos};
		}forEach(_roads);

		_move = _tgroup addWaypoint [_dropos,0];
		_move setWaypointBehaviour "CARELESS";
		_move setWaypointTimeout [30,30,30];
		_move setWaypointType "TR UNLOAD";
		_move setWaypointCompletionRadius 50;

		_wp = _tgroup addWaypoint [_frompos,0];
		_wp setWaypointType "MOVE";
		_wp setWaypointBehaviour "CARELESS";
		_wp setWaypointCompletionRadius 25;

		_wp = _tgroup addWaypoint [_frompos,0];
		_wp setWaypointType "SCRIPTED";
		_wp setWaypointCompletionRadius 25;
		_wp setWaypointStatements ["true","[vehicle this] call OT_fnc_cleanup"];
	};
};
sleep 10;

_wp1 = _group1 addWaypoint [_attackpos,100];
_wp1 setWaypointType "SAD";
_wp1 setWaypointBehaviour "COMBAT";
_wp1 setWaypointSpeed "FULL";

if !(_byair) then {
	_wp2 = _group2 addWaypoint [_attackpos,100];
	_wp2 setWaypointType "SAD";
	_wp2 setWaypointBehaviour "COMBAT";
	_wp2 setWaypointSpeed "FULL";
};

// Once the attack is over and attack position is unloaded, despawn all alive units.
// Bodies are left for looting purposes
[
	{server getVariable ["NATOattacking",""] isEqualTo "" && {!([_this # 2] call OT_fnc_inSpawnDistance)}},
	{
		_this params ["_group1", "_group2", "_attackpos"];
		{
			if (alive _x) then {continue};
			[_x] call OT_fnc_cleanup;
		} forEach (units _group1);

		{
			if (alive _x) then {continue};
			[_x] call OT_fnc_cleanup;
		} forEach (units _group2);
	},
	[_group1, _group2, _attackpos],
	(120 * 60) // Timeout 2 hours
] call CBA_fnc_waitUntilAndExecute;

if(_tgroup isEqualType grpNull) then {

	[_veh,_tgroup,_frompos,_byair] spawn {
		//Ejects crew from vehicles when they take damage or stay relatively still for too long (you know, like when they ram a tree for 4 hours)
		params ["_veh","_tgroup","_frompos","_byair"];
		private _done = false;
		private _stillfor = 0;
		private _lastpos = getPos _veh;
		while{sleep 10;!_done} do {
			if(isNull _veh) exitWith {};
			if(isNull _tgroup) exitWith {};
			if(!alive _veh) exitWith {};
			private _eject = false;
			if((damage _veh) > 0.5 && ((getPos _veh) select 2) < 2) then {
				//Vehicle damaged (and on the ground)
				_eject = true;
			};
			if(_veh distance _lastpos < 0.5) then {
				_stillfor = _stillfor + 10;
				if(_stillfor > 60) then {
					//what are you doing? gtfo
					_eject = true;
				};
			}else{
				_stillfor = 0;
			};
			if(_eject) exitWith {
				while {(count (waypoints _tgroup)) > 0} do {
				 	deleteWaypoint ((waypoints _tgroup) select 0);
				};
				commandStop (driver _veh);
				{
					unassignVehicle _x;
					commandGetOut _x;
				}forEach(crew _veh);
				_done = true;
				waitUntil {sleep 2;(count crew _veh) isEqualTo 0};
				[_veh] call OT_fnc_cleanup;
			};
			if(_byair && (_veh getVariable ["OT_deployedTroops",false])) exitWith {
				[_veh,_frompos] spawn OT_fnc_landAndCleanupHelicopter;
				_done = true;
			};

		};
	};
};
