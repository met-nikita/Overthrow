if (!isServer) exitWith {};
if(count(vehicles) > 200) exitWith {};
if(OT_spawnVehiclePercentage isEqualTo 0) exitWith {};
sleep random 1;
private _count = 0;

params ["_town","_spawnid"];
private _posTown = server getVariable _town;
private _groups = [];

private _mSize = 300;
if(_town in OT_capitals + OT_sprawling) then {//larger search radius
	_mSize = 500;
};

private _count = 0;
private _pop = server getVariable format["population%1",_town];
private _stability = server getVariable format ["stability%1",_town];
private _numVeh = 1;
if(_pop > 15) then {
	_numVeh = 3 + round(_pop * OT_spawnVehiclePercentage);
};
if(_town isEqualTo (server getVariable "spawntown") && !(_town in (server getVariable ["NATOabandoned",[]]))) then {
	_numVeh = 6;
};
if(_numVeh > 6) then {_numVeh = 6};
private _loops = 0;
while {(_count < _numVeh) && (_loops < 50)} do {
	private _start = [[[_posTown,_mSize]]] call BIS_fnc_randomPos;
	_roads = _start nearRoads 75;
	if(count _roads > 0) then {
		_road = _roads select 0;
		_pos = getPosATL _road;
		_vehtype = "";
		if(_pop > 600) then {
			_vehtype = selectRandom (OT_vehTypes_civ - OT_vehTypes_civignore);
		}else{
			_vehtype = OT_vehTypes_civ selectRandomWeighted OT_vehWeights_civ;
		};
		if !(_vehtype in OT_vehTypes_civignore) then {
			_dirveh = 0;
			_roadscon = roadsConnectedTo _road;
			if (count _roadscon isEqualTo 2) then {
				_dirveh = (_road getDir (_roadscon select 0));
				if(isNil "_dirveh") then {_dirveh = random 359};
				_posVeh = _pos getPos [6, _dirveh + 90];
				_posEmpty = _posVeh findEmptyPosition [4,15,_vehtype];
				 //dont bother if the position isnt empty for 4m
				if(count _posEmpty isEqualTo 0) then {
					_posVeh = [];
				}else{
					if((_posVeh distance _posEmpty) > 4) then {_posVeh = []};
				};
				if(count _posVeh > 0) then {
					_veh = _vehtype createVehicle _posEmpty;
					_veh setVariable ["ambient",true,true];
					clearItemCargoGlobal _veh;
					_veh setFuel (0.2 + (random 0.5));

					_veh setDir _dirveh;
					_count = _count + 1;

					if((random 100) > 90 && (count allUnits < 300)) then {
						_group = createGroup civilian;
						_group setVariable ["lambs_danger_disableGroupAI", true];
						_groups pushBack _group;
						_civ = _group createUnit [OT_civType_local, _pos, [],0, "NONE"];
						_civ setBehaviour "SAFE";
						[_civ] call OT_fnc_initCivilian;
						[_civ, call OT_fnc_randomLocalIdentity] call OT_fnc_applyIdentity;
						_civ moveInDriver _veh;

						_region  = server getVariable format["region_%1",_town];
						_moveto = _posVeh;
						if(isNil "_region") then {
							_moveto = _posVeh call OT_fnc_getRandomRoadPosition;
						}else{
							_dest = selectRandom (server getVariable format["towns_%1",_region]);
							_moveto = _dest call OT_fnc_getRandomRoadPosition;
						};

						_wp = _group addWaypoint [_moveto,0];

						_wp setWaypointType "MOVE";
						_wp setWaypointSpeed "LIMITED";
						_wp setWaypointBehaviour "SAFE";
						_wp setWaypointCompletionRadius 60;
						_wp setWaypointStatements ["true","[vehicle this] call OT_fnc_cleanup;unassignVehicle this;[group this] call OT_fnc_cleanup;"];
					}else{
						if(_stability < 50 && (random 100) > 80) then {
							_veh setDamage [1,false]; //salvage wreck
							_veh enableDynamicSimulation true;
						};
					};
					_groups pushBack _veh;
					sleep 0.5;
				};
			};
		};
	};
	_loops = _loops + 1;
};
spawner setVariable [_spawnid,(spawner getVariable [_spawnid,[]]) + _groups,false];
