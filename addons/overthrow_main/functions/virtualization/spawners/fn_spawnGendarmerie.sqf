if (!isServer) exitWith {};

params ["_town","_spawnid"];

private _abandoned = server getVariable ["NATOabandoned",[]];
private _stability = server getVariable format["stability%1",_town];
if (_town in _abandoned) exitWith {};

private _posTown = server getVariable _town;
private _groups = [];
private _numNATO = server getVariable format["garrison%1",_town];
private _count = 0;
private _range = 350;

if(_town in OT_capitals) then {
	_range = 900;
};

//record the spawn ID for job tasks
spawner setVariable [format["spawnid%1",_town],_spawnid];

while {_count < _numNATO} do {

	private _home = _town call OT_fnc_getRandomRoadPosition;
	private _pos = _home findEmptyPosition [2,50];

	if !(_pos isEqualTo []) then {

		private _groupcount = 0;
		private _group = createGroup west;
		_group setVariable ["VCM_TOUGHSQUAD",true,true];
		_group setVariable ["VCM_NORESCUE",true,true];
		_group deleteGroupWhenEmpty true;
		_groups pushBack _group;

		private _toSpawn = OT_NATO_Unit_PoliceCommander;
		if (_stability < 25) then {_toSpawn = OT_NATO_Unit_PoliceCommander_Heavy};
		private _civ = _group createUnit [_toSpawn, _home, [],0, "NONE"];

		_civ setVariable ["garrison",_town,false];
		[_civ] joinSilent _group;
		_civ setRank "CORPORAL";
		_civ setBehaviour "SAFE";

		[_civ,_town] call OT_fnc_initGendarm;

		_toSpawn = OT_NATO_Unit_Police;
		if (_stability < 25) then {_toSpawn = OT_NATO_Unit_Police_Heavy};
		_civ = _group createUnit [_toSpawn, _pos, [],0, "NONE"];
		_civ setVariable ["garrison",_town,false];
		[_civ] joinSilent _group;
		_civ setRank "PRIVATE";
		[_civ,_town] call OT_fnc_initGendarm;
		_civ setBehaviour "SAFE";
		if (_stability < 25) then {
			_toSpawn = OT_NATO_Unit_PoliceMedic_Heavy;
			_civ = _group createUnit [_toSpawn, _pos, [],0, "NONE"];
			_civ setVariable ["garrison",_town,false];
			[_civ] joinSilent _group;
			_civ setRank "PRIVATE";
			[_civ,_town] call OT_fnc_initGendarm;
			_civ setBehaviour "SAFE";
		};

		sleep 0.5;
		_group call OT_fnc_initGendarmPatrol;
		_range = _range + 50;
		_count = _count + 2;

		{
			_x addCuratorEditableObjects[units _group,false];
		}forEach(allCurators);
	};
};

spawner setVariable [_spawnid,(spawner getVariable [_spawnid,[]]) + _groups,false];
