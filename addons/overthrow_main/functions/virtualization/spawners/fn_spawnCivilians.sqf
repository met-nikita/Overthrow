params ["_town","_spawnid"];
sleep random 0.2;

spawner setVariable [format["townspawnid%1",_town],_spawnid,false];

private _hometown = _town;
private _groups = [];

private _pop = server getVariable format["population%1",_town];
private _stability = server getVariable format ["stability%1",_town];
private _posTown = server getVariable _town;

waitUntil {!isNil "OT_economyLoadDone"};

private _mSize = 350;
if(_town in OT_capitals) then {
	_mSize = 900;
};
private _numciv = 0;

if(_pop > 5) then {
	_numCiv = round(_pop * OT_spawnCivPercentage);
	if(_numCiv < 5) then {
		_numCiv = 5;
	};
}else {
	_numCiv = _pop;
};

if(_numCiv > 50) then {
	_numCiv = 50;
};

private _hour = date select 3;

/*
private _church = server getVariable [format["churchin%1",_town],[]];
if !(_church isEqualTo []) then {
	//spawn the priest
	_group = createGroup civilian;
	_group setBehaviour "SAFE";
	_groups pushback _group;
	_pos = [[[_church,20]]] call BIS_fnc_randomPos;
	_civ = _group createUnit [OT_civType_priest, _pos, [],0, "NONE"];
	[_civ] call OT_fnc_initPriest;
	sleep 0.3;
};*/

private _count = 0;

private _pergroup = 1;
if(_numCiv > 8) then {_pergroup = 2};
if(_numCiv > 16) then {_pergroup = 4};

// Spawn a mayor for the town
private _mayorpos = _town call OT_fnc_getRandomRoadPosition;
private _group = createGroup [civilian,true];
_group setBehaviour "SAFE";
_groups pushBack _group;
_mayor = _group createUnit ["C_Man_formal_1_F", _mayorpos, [],0, "NONE"];
_mayor setBehaviour "CARELESS";
_mayor setVariable ["hometown",_hometown,true];
[_mayor] call OT_fnc_initMayor;
_group call OT_fnc_initCivilianGroup;


// Spawn the rest of the civvies
while {_count < _numCiv} do {
	private _groupCount = 0;
	private _group = createGroup [civilian,true];
	_group setBehaviour "SAFE";
	_groups pushBack _group;

	private _home = _town call OT_fnc_getRandomRoadPosition;
	while {(_groupcount < _pergroup) && (_count < _numCiv)} do {
		_pos = _home getPos [10, random 360];
		_civ = _group createUnit [OT_civType_local, _pos, [],0, "NONE"];
		_civ setBehaviour "SAFE";
		_civ setVariable ["hometown",_hometown,true];
		[_civ] call OT_fnc_initCivilian;

		private _identity = call OT_fnc_randomLocalIdentity;
		[_civ,_identity] call OT_fnc_applyIdentity;
		_count = _count + 1;
		_groupcount = _groupcount + 1;
		sleep 0.5;
	};
	_group call OT_fnc_initCivilianGroup;
};
sleep 0.3;
//Do gangs
private _gangs = OT_civilians getVariable [format["gangs%1",_town],[]];
{
	private _gangid = _x;
	private _gang = OT_civilians getVariable [format["gang%1",_gangid],[]];
	_gang params ["_members"];

	if (!isNil "_members" && {_members isEqualType []}) then {
		private _group = createGroup [opfor,true];
		_group setVariable ["VCM_TOUGHSQUAD",true,true];
		_group setVariable ["VCM_NORESCUE",true,true];
		_groups pushBack _group;
		spawner setVariable [format["gangspawn%1",_gangid],_group,true];
		if(count _gang > 4) then { //Filter out old gangs
			private _home = _gang select 4; //camp position

			//Spawn the camp
			_veh = createVehicle ["Campfire_burning_F",_home,[],0,"CAN_COLLIDE"];
			_groups pushBack _veh;

			_numtents = 2 + round(random 3);
			_count = 0;

			while {_count < _numtents} do {
				//this code is in tents
				_d = random 360;
				_p = _home getPos [(2 + random 7), _d];
				_p = _p findEmptyPosition [1,40,"Land_TentDome_F"];
				_veh = createVehicle ["Land_TentDome_F",_p,[],0,"CAN_COLLIDE"];
				_veh setDir _d;
				_groups pushBack _veh;
				_count = _count + 1;
			};

			//And the gang leader in his own group
			private _leaderGroup = createGroup [opfor,true];
			_leaderGroup setVariable ["VCM_TOUGHSQUAD",true,true];
			_leaderGroup setVariable ["VCM_NORESCUE",true,true];
			private _pos = _home getPos [10, random 360];
			_civ = _leaderGroup createUnit [OT_CRIM_Unit, _pos, [],0, "NONE"];
			_civ setRank "COLONEL";
			_civ setBehaviour "SAFE";
			_civ setVariable ["NOAI",true,false];
			[_civ] joinSilent nil;
			[_civ] joinSilent _leaderGroup;
			_civ setVariable ["OT_gangid",_gangid,true];
			[_civ,_town,_gangid] call OT_fnc_initCrimLeader;
			_civ setVariable ["hometown",_town,true];

			_wp = _leaderGroup addWaypoint [_home,0];
			_wp setWaypointType "GUARD";
			_wp = _leaderGroup addWaypoint [_home,0];
	        _wp setWaypointType "CYCLE";

			_groups pushBack _leaderGroup;

			{
				_x addCuratorEditableObjects [[_civ]];
			}forEach(allCurators);

			{
				private _civid = _x;
				private _ident = (OT_civilians getVariable [format["%1",_civid],[]]);
				_ident params ["_identity"];

				private _pos = _pos getPos [10, random 360];
				private _civ = _group createUnit [OT_CRIM_Unit, _pos, [],0, "NONE"];
				[_civ] joinSilent nil;
				[_civ] joinSilent _group;

				[_civ,_town,_identity,_gangid] call OT_fnc_initCriminal;

				_civ setVariable ["OT_gangid",_gangid,true];
				_civ setVariable ["OT_civid",_civid,true];
				_civ setBehaviour "SAFE";
				_civ setVariable ["hometown",_town,true];

				{
					_x addCuratorEditableObjects [[_civ]];
				}forEach(allCurators);

				sleep 0.3;
			}forEach(_members);
			[_group,_posTown] call OT_fnc_initCriminalGroup;
		};
	};
}forEach(_gangs);

spawner setVariable [_spawnid,(spawner getVariable [_spawnid,[]]) + _groups,false];
