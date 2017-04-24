createDialog 'OT_dialog_reverse';
private ["_playerstock","_town","_standing","_s"];

_playerstock = player call OT_fnc_unitStock;

private _cursel = lbCurSel 1500;
lbClear 1500;
private _numitems = 0;
private _blueprints = server getVariable ["GEURblueprints",[]];
{
	_cls = _x select 0;
	if !(_cls in _blueprints) then {
		_name = "";
		_pic = "";
		if(_cls isKindOf ["Default",configFile >> "CfgWeapons"]) then {
			_name = _cls call ISSE_Cfg_Weapons_GetName;
			_pic = _cls call ISSE_Cfg_Weapons_GetPic;
		};
		if(_cls isKindOf ["Default",configFile >> "CfgMagazines"]) then {
			_name = _cls call ISSE_Cfg_Magazine_GetName;
			_pic = _cls call ISSE_Cfg_Magazine_GetPic;
		};
		if(_cls isKindOf "Bag_Base") then {
			_name = _cls call ISSE_Cfg_Vehicle_GetName;
			_pic = _cls call ISSE_Cfg_Vehicle_GetPic;
		};
		_idx = lbAdd [1500,_name];
		lbSetPicture [1500,_idx,_pic];
		lbSetData [1500,_idx,_cls];
		_numitems = _numitems + 1;
	};
}foreach(_playerstock);

{
	if (!(_x isKindOf "CaManBase") and alive _x) then {
		_cls = typeof _x;
		_name = _cls call ISSE_Cfg_Vehicle_GetName;
		_pic = _cls call ISSE_Cfg_Vehicle_GetPic;
		_idx = lbAdd [1500,_name];
		lbSetPicture [1500,_idx,_pic];
		lbSetData [1500,_idx,_cls];
		_numitems = _numitems + 1;
	};
}foreach(OT_factoryPos nearObjects ["AllVehicles", 50]);

if(_cursel >= _numitems) then {_cursel = 0};
lbSetCurSel [1500, _cursel];