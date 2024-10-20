params ["_pos","_name","_spawnid"];

private _count = 0;
private _groups = [];

private _numCiv = server getVariable[format["%1employ",_name],0];
if(_numCiv isEqualTo 0) exitWith {[]};

private _group = createGroup resistance;
_group setBehaviour "SAFE";
_groups pushBack _group;

while {_count < _numCiv} do {
	_pos = [[[_pos,50]]] call BIS_fnc_randomPos;
	_civ = _group createUnit [OT_civType_worker, _pos, [],0, "NONE"];
	_civ setBehaviour "SAFE";
	private _identity = call OT_fnc_randomLocalIdentity;
	_identity set [1, ""]; // Retain original worker clothes
	[_civ, _identity] call OT_fnc_applyIdentity;
	_civ setVariable ["employee",_name, true];
	_count = _count + 1;
	sleep 0.3;
};
spawner setVariable [format["employees%1",_name],_group,false];

private _dest = _pos getPos [random 100, random 360];
private _bdg = [_pos,["Building"]] call OT_fnc_getRandomBuilding;
if !(_bdg isEqualType true) then { _dest = getPos(_bdg)};

private _wp = _group addWaypoint [_dest,0];
private _start = _dest;
_wp setWaypointType "MOVE";
_wp setWaypointSpeed "LIMITED";
_wp setWaypointCompletionRadius 40;
_wp setWaypointTimeout [0, 4, 8];

_dest = _pos getPos [random 100, random 360];
_bdg = [_start,["Building"]] call OT_fnc_getRandomBuilding;
if !(_bdg isEqualType true) then { _dest = getPos(_bdg)};

_wp = _group addWaypoint [_dest,0];
_wp setWaypointType "MOVE";
_wp setWaypointSpeed "LIMITED";
_wp setWaypointCompletionRadius 10;
_wp setWaypointTimeout [20, 40, 80];

_wp = _group addWaypoint [_start,0];
_wp setWaypointType "CYCLE";

spawner setVariable [_spawnid,(spawner getVariable [_spawnid,[]]) + _groups,false];
