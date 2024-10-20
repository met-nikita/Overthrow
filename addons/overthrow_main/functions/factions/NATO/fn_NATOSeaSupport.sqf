params ["_frompos","_attackpos","_delay"];
sleep _delay;

private _dir = (_frompos getDir _attackpos);
_pos = _frompos findEmptyPosition [50,200,OT_NATO_Vehicle_Boat_Small];
if (count _pos == 0) then {_pos = _frompos findEmptyPosition [20,200,OT_NATO_Vehicle_Boat_Small]};

_group = createGroup blufor;
_veh = createVehicle [OT_NATO_Vehicle_Boat_Small, _pos, [], 0,""];
_veh setVariable ["garrison","HQ",false];
_veh setDir (_dir);
_group addVehicle _veh;
createVehicleCrew _veh;
{
    [_x] joinSilent _group;
    _x setVariable ["garrison","HQ",false];
    _x setVariable ["NOAI",true,false];
}forEach(crew _veh);
_allunits = (units _group);
sleep 1;

_wp = _group addWaypoint [ASLToATL _attackpos,20];
_wp setWaypointType "SAD";
_wp setWaypointBehaviour "COMBAT";
_wp setWaypointSpeed "FULL";
_wp setWaypointTimeout [600,600,600];

_wp = _group addWaypoint [_frompos,2000];
_wp setWaypointType "SCRIPTED";
_wp setWaypointStatements ["true","[vehicle this] call OT_fnc_cleanup"];


