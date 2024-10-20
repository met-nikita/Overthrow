private _sorted = [];
private _myunits = groupSelectedUnits player;

{
    player groupSelectUnit [_x, false];
} forEach (groupSelectedUnits player);

_myunits params ["_tt"];
if(!isNull objectParent _tt) then {
	_sorted = [objectParent _tt];
}else{
	private _objects = _tt nearEntities [["Car","ReammoBox_F","Air","Ship"],20];
	if(count _objects isEqualTo 0) exitWith {
		"Cannot find any containers or vehicles within 20m of first selected unit" call OT_fnc_notifyMinor;
	};
	_sorted = [_objects,[],{_x distance _tt},"ASCEND"] call BIS_fnc_SortBy;
};

if(count _sorted isEqualTo 0) exitWith {};
private _target = _sorted select 0;

{
    if ((typeOf vehicle _x) == "OT_I_Truck_recovery" && (driver vehicle _x) == _x) exitWith {
        [_x] spawn OT_fnc_recover;
    };
	[_x,_target] spawn {
		private _active = true;
		private _wasincar = false;
		private _car = objNull;

		private _unit = _this select 0;

		_unit setVariable ["NOAI",true,true];
		_unit setBehaviour "SAFE";
		[_unit, ""] remoteExec ["switchMove", 0, false];

		if(!isNull objectParent _unit) then {
			_car = (objectParent _unit);
			doGetOut _unit;
			_wasincar = true;
		};

		_t = _this select 1;

        _unit globalChat format["Looting bodies within 100m into the %1",(typeOf _t) call OT_fnc_vehicleGetName];

        private _istruck = true;
        if(count _this isEqualTo 2) then {
        	_istruck = (_t isKindOf "Truck_F") || (_t isKindOf "ReammoBox_F");
        };

		_unit doMove ASLToAGL (getPosASL _t);

		_timeout = time + 30;
		waitUntil {sleep 1; (!alive _unit) || (isNull _t) || (_unit distance _t < 10) || (_timeOut < time) || (unitReady _unit)};
		if(!alive _unit || (isNull _t) || (_timeOut < time)) exitWith {};

		if !([_unit,_t] call OT_fnc_dumpStuff) then {
			_unit globalChat "This vehicle is full, cancelling loot order";
			_active = false;
		};
        private _weapons = (_t nearObjects ["WeaponHolder", 100]) + (_t nearEntities ["WeaponHolderSimulated", 100]);
        _unit globalChat format["Looting %1 weapons",count _weapons];
        {
            _weapon = _x;
            _s = (weaponsItems _weapon) select 0;
            if(!isNil {_s}) then {
    			_cls = (_s select 0);
    			_i = _s select 1;
    			if(_i != "") then {_t addItemCargoGlobal [_i,1]};
    			_i = _s select 2;
    			if(_i != "") then {_t addItemCargoGlobal [_i,1]};
    			_i = _s select 3;
    			if(_i != "") then {_t addItemCargoGlobal [_i,1]};

                if (!(_t canAdd (_cls call BIS_fnc_baseWeapon)) && !_istruck) exitWith {
    				_unit globalChat "This vehicle is full, cancelling loot order";
    				_active = false;
    			};
                _t addWeaponCargoGlobal [_cls call BIS_fnc_baseWeapon,1];
    			deleteVehicle _weapon;
            };
        }forEach(_weapons);

		while {_active} do {
			_deadguys = [];
			{
				if !(_x isKindOf "CAManBase") then {continue};
				if (_x distance _t < 100) then {
					_deadguys pushBack _x;
				};
			} forEach allDeadMen;

			if(count _deadguys isEqualTo 0) exitWith {_unit globalChat "All done!"};
            _unit globalChat format["%1 bodies to loot",count _deadguys];
			_sorted = [_deadguys,[],{_x distance _t},"ASCEND"] call BIS_fnc_SortBy;

			_timeout = time + 30;
			_deadguy = _sorted select 0;
			_deadguy setVariable ["OT_looted",true,true];
			_deadguy setVariable ["OT_lootedAt",time,true];

			_unit doMove ASLToAGL (getPosASL _deadguy);
			[_unit,1] call OT_fnc_experience;

			waitUntil {sleep 1; (!alive _unit) || (isNull _t) || (_unit distance2D _deadguy < 12) || (_timeOut < time)};
			if((!alive _unit) || (_timeOut < time)) exitWith {_unit globalChat "Cant get to a body, cancelling loot order"};

			[_deadguy,_unit] call OT_fnc_takeStuff;
			sleep 2;
			[_deadguy] call OT_fnc_cleanupUnit;
			_timeout = time + 30;
			_unit doMove ASLToAGL (getPosASL _t);
			waitUntil {sleep 1; (!alive _unit) || (isNull _t) || (_unit distance _t < 12) || (_timeOut < time)};
			if((!alive _unit) || (_timeOut < time)) exitWith {};

			if !([_unit,_t] call OT_fnc_dumpStuff) exitWith {
				_unit globalChat "This vehicle is full, cancelling loot order";
				_active = false;
			};

			sleep 1;
		};

		_unit setVariable ["NOAI",true,true];
		if(_wasincar) then {
			_unit assignAsCargo _car;
			[_unit] orderGetIn true;
		};
	};
}forEach(_myunits);
