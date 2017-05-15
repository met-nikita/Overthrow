private ["_b","_s","_town","_standing","_cls","_num","_price","_idx"];
_idx = lbCurSel 1500;
_cls = lbData [1500,_idx];

_town = (getPos player) call OT_fnc_nearestTown;
_standing = player getVariable format['rep%1',_town];

_price = lbValue [1500,_idx];
if(_price == -1) exitWith {};

private _chems = server getVariable ["reschems",0];
private _cost = cost getVariable [_cls,[0,0,0,0]];
if(_cls in OT_allExplosives and _chems < (_cost select 3)) exitWith {format["You need %1 chemicals",_cost select 3] call OT_fnc_notifyMinor};

_money = player getVariable "money";
if(_money < _price) exitWith {"You cannot afford that!" call OT_fnc_notifyMinor};

call {
	if(_cls == "Set_HMG") exitWith {
		_pos = (getpos player) findEmptyPosition [5,100,"C_Quadbike_01_F"];
		if (count _pos == 0) exitWith {"Not enough space, please clear an area nearby" call OT_fnc_notifyMinor};

		player setVariable ["money",_money-_price,true];
		_veh = "C_Quadbike_01_F" createVehicle _pos;
		[_veh,getPlayerUID player] call OT_fnc_setOwner;
		clearWeaponCargoGlobal _veh;
		clearMagazineCargoGlobal _veh;
		clearBackpackCargoGlobal _veh;
		clearItemCargoGlobal _veh;
		_veh addBackpackCargoGlobal ["I_HMG_01_high_weapon_F", 1];
		_veh addBackpackCargoGlobal ["I_HMG_01_support_high_F", 1];

		player reveal _veh;
		format["You bought a Quad Bike w/ HMG for $%1",_price] call OT_fnc_notifyMinor;
		playSound "3DEN_notificationDefault";
	};
	if(OT_interactingWith getVariable ["factionrep",false] and ((_cls isKindOf "Land") or (_cls isKindOf "Air"))) exitWith {
		_blueprints = server getVariable ["GEURblueprints",[]];
		if !(_cls in _blueprints) then {
			_blueprints pushback _cls;
			server setVariable ["GEURblueprints",_blueprints,true];
			_factionName = OT_interactingWith getVariable ["factionrepname",""];
			format["%1 has bought %2 blueprint from %3",name player,_cls call ISSE_Cfg_Vehicle_GetName,_factionName] remoteExec ["OT_fnc_notifyMinor",0,false];
			closeDialog 0;
		};
	};
	if(_cls isKindOf "Man") exitWith {
		[_cls,getpos player,group player] call recruitSoldier;
	};
	if(_cls in OT_allSquads) exitWith {
		[_cls,getpos player] call recruitSquad;
	};
	if(_cls == OT_item_UAV) exitWith {
		_pos = (getpos player) findEmptyPosition [5,100,_cls];
		if (count _pos == 0) exitWith {"Not enough space, please clear an area nearby" call OT_fnc_notifyMinor};

		player setVariable ["money",_money-_price,true];

		_veh = createVehicle [_cls, _pos, [], 0,""];
		_crew = createVehicleCrew _veh;
		{
			[_x,getPlayerUID player] call OT_fnc_setOwner;
		}foreach(crew _veh);

		[_veh,getPlayerUID player] call OT_fnc_setOwner;

		if("ItemGPS" in (assignedItems player)) then {
			player addItem OT_item_UAVterminal;
		}else{
			if !(OT_item_UAVterminal in (assignedItems player)) then {
				player linkItem OT_item_UAVterminal;
			};
		};

		player connectTerminalToUAV _veh;

		player reveal _veh;
		format["You bought a Quadcopter",_cls call ISSE_Cfg_Vehicle_GetName] call OT_fnc_notifyMinor;
		playSound "3DEN_notificationDefault";
		hint "To use a UAV, scroll your mouse wheel to 'Open UAV Terminal' then right click your green copter on the ground and 'Connect terminal to UAV'";
	};
	if(_cls in OT_allVehicles) exitWith {
		_pos = (getpos player) findEmptyPosition [5,100,_cls];
		if (count _pos == 0) exitWith {"Not enough space, please clear an area nearby" call OT_fnc_notifyMinor};

		player setVariable ["money",_money-_price,true];
		_veh = _cls createVehicle _pos;
		[_veh,getPlayerUID player] call OT_fnc_setOwner;
		clearWeaponCargoGlobal _veh;
		clearMagazineCargoGlobal _veh;
		clearBackpackCargoGlobal _veh;
		clearItemCargoGlobal _veh;

		if(_cls == OT_vehType_service) then {
			_veh addItemCargoGlobal ["ToolKit", 1];
			[_veh,3,"ACE_Wheel"] call ace_repair_fnc_addSpareParts;
		};

		player reveal _veh;
		format["You bought a %1 for $%2",_cls call ISSE_Cfg_Vehicle_GetName,_price] call OT_fnc_notifyMinor;
		playSound "3DEN_notificationDefault";
	};
	if(_cls isKindOf "Ship") exitWith {
		_pos = (getpos player) findEmptyPosition [5,100,_cls];
		if (count _pos == 0) exitWith {"Not enough space, please clear an area nearby" call OT_fnc_notifyMinor};

		player setVariable ["money",_money-_price,true];
		_veh = _cls createVehicle _pos;
		[_veh,getPlayerUID player] call OT_fnc_setOwner;
		clearWeaponCargoGlobal _veh;
		clearMagazineCargoGlobal _veh;
		clearBackpackCargoGlobal _veh;
		clearItemCargoGlobal _veh;

		player reveal _veh;
		format["You bought a %1",_cls call ISSE_Cfg_Vehicle_GetName] call OT_fnc_notifyMinor;
		playSound "3DEN_notificationDefault";
	};
	if(_cls in OT_allClothing) exitWith {
		[-_price] call money;

		if((backpack player != "") and (player canAdd _cls)) then {
			player addItemToBackpack _cls;
			"Clothing added to your backpack" call OT_fnc_notifyMinor;
		}else{
			player forceAddUniform _cls;
		};
		playSound "3DEN_notificationDefault";
	};
	if(_cls == "V_RebreatherIA") exitWith {
		[-_price] call money;

		if((backpack player != "") and (player canAdd _cls)) then {
			player addItemToBackpack _cls;
			"Rebreather added to your backpack" call OT_fnc_notifyMinor;
		}else{
			player addVest _cls;
		};
		playSound "3DEN_notificationDefault";
	};
	if((_cls isKindOf ["Launcher",configFile >> "CfgWeapons"]) or (_cls isKindOf ["Rifle",configFile >> "CfgWeapons"]) or (_cls isKindOf ["Pistol",configFile >> "CfgWeapons"])) exitWith {
		[-_price] call money;

		_box = false;
		{
			_owner = _x call OT_fnc_getOwner;
			if(!isNil "_owner") then {
				if(_owner == getplayerUID player) exitWith {_box = _x};
			};
		}foreach(nearestObjects [getpos player, [OT_item_Storage],1200]);

		player addWeapon _cls;

		playSound "3DEN_notificationDefault";
	};
	if(_cls isKindOf ["CA_Magazine",configFile >> "CfgMagazines"]) exitWith {
		if(_cls in OT_allExplosives) then {
			_server setVariable ["reschems",_chems - (_cost select 3),true];
		};
		[-_price] call money;
		player addMagazine _cls;
		playSound "3DEN_notificationDefault";
	};
	_handled = true;
	if(_cls isKindOf "Bag_Base") then {
		if(backpack player != "") exitWith {"You already have a backpack" call OT_fnc_notifyMinor;_handled = false};
	}else{
		if !(player canAdd [_cls,1]) exitWith {"There is not enough room in your inventory" call OT_fnc_notifyMinor;_handled = false};
	};

	if(_handled) then {
		playSound "3DEN_notificationDefault";
		if (_cls in OT_illegalItems) exitWith {
			[-_price] call money;
			player addItem _cls;

			if(player call unitSeenNATO) then {
				[player] remoteExec ["OT_fnc_NATOsearch",2,false];
			};
		};
		if (_cls in OT_allStaticBackpacks) exitWith {
			[-_price] call money;
			player addBackpack _cls;
		};
		if (_cls in OT_allOptics) exitWith {
			[-_price] call money;
			player addItem _cls;
		};

		_b = player getVariable ["shopping",objNull];
		_bp = _b getVariable "shop";
		if(isNil "_bp") exitWith {};

		_s = [];
		_active = server getVariable [format["activeshopsin%1",_town],[]];
		{
			_pos = _x select 0;
			if(format["%1",_pos] == _bp) exitWith {
				_s = _x select 1;
			};
		}foreach(_active);

		_done = false;
		_soldout = false;
		_stockidx = 0;
		{
			if(((_x select 0) == _cls) && ((_x select 1) > 0)) exitWith {
				_num = (_x select 1)-1;
				if(_num == 0) then {
					_soldout = true;
				};
				_x set [1,_num];
				_done = true;
			};
			_stockidx = _stockidx + 1;
		}foreach(_s);

		if(_done) then {
			if(_soldout) then {
				_s deleteAt _stockidx;
			};
			player setVariable ["money",_money-_price,true];
			server setVariable [format["activeshopsin%1",_town],_active,true];
			if(_cls isKindOf "Bag_Base") then {
				player addBackpack _cls;
			}else{
				player addItem _cls;
			};
			_s = [];
			{
				_pos = _x select 0;
				if(format["%1",_pos] == _bp) exitWith {
					_s = _x select 1;
				};
			}foreach(server getVariable [format["activeshopsin%1",_town],[]]);
			[_town,_standing,_s] call buyDialog;
		};
	};
};
