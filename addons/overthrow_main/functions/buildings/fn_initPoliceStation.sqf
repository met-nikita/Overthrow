private _pos = _this select 0;
private _post = (_pos nearObjects ["Land_Cargo_House_V3_F",10]) select 0;
private _town = _pos call OT_fnc_nearestTown;

_garrison = server getVariable [format['police%1',_town],-1];
if(_garrison == -1) then {
	//First time
	server setVariable [format['policepos%1',_town],_pos,true];

	private _soldier = "Police" call OT_fnc_getSoldier;

	private _spawnid = spawner getVariable [format["townspawnid%1",_town],-1];
	private _groups = spawner getVariable [_spawnid,[]];

	_builder = name player;
	{
		[_x,format["New Police Station: %1",_town],format["%1 built a new police station %2",_builder,_town]] call BIS_fnc_createLogRecord;
	}forEach([] call CBA_fnc_players);

	server setVariable [format['police%1',_town],2,true];

	_count = 0;
	_range = 15;
	_spawned = [];
	_group = createGroup resistance;
	_groups pushBack _group;
	while {_count < 2} do {
		_start = [[[_pos,_range]]] call BIS_fnc_randomPos;

		_p = [[[_start,20]]] call BIS_fnc_randomPos;

		_civ = [_soldier,_p,_group,false] call OT_fnc_createSoldier;
		_civ setVariable ["polgarrison",_town,true];
		[_civ] joinSilent _group;
		_civ setRank "SERGEANT";
		[_civ,_town] call OT_fnc_initPolice;
		_civ setBehaviour "SAFE";

		_count = _count + 1;
	};
	_group call OT_fnc_initPolicePatrol;
	spawner setVariable [_spawnid,_groups,false];
};

_mrkid = format["%1-police",_town];
createMarkerLocal [_mrkid,_pos];
_mrkid setMarkerShapeLocal "ICON";
_mrkid setMarkerTextLocal "2";
_mrkid setMarkerTypeLocal "o_installation";
_mrkid setMarkerColorLocal "ColorGUER";
_mrkid setMarkerAlpha 1;
