private _items = [];
private _category = "";
private _target = _this;
private _categoryItems = [];


if(_this isEqualType []) then {
	_category = _this select 1;
	_target = _this select 0;

	if(_category isEqualTo "Hardware") then {
		_categoryItems = ["OT_Steel","OT_Wood","OT_Plastic","OT_Fertilizer"];
	};
	if(_category isEqualTo "Clothing") then {
		_categoryItems = OT_allLegalClothing + OT_allGlasses + OT_allGoggles + OT_allFacewear;
	};
	{
		if((_x select 0) isEqualTo _category) exitWith {
			{
				_categoryItems pushBack _x;
			}forEach(_x select 1);
		};
	}forEach(OT_items);
};

private _allCargo = {
	private _target = _this;
	private _myitems = [];
	if(_target isKindOf "CAManBase") then {
		_myitems = ((items _target) - (weapons _target)) + (magazines _target);
		{
			{
				if(_x isEqualType "") then {
					if (!(_x isEqualTo "") && !(_x isEqualTo (binocular _target))) then {
						if(_forEachIndex isEqualTo 0) then {
							_myitems pushBack (_x call BIS_fnc_baseWeapon);
						}else{
							_myitems pushBack _x;
						};
					};
				};
				if(_x isEqualType []) then {
					if (!(_x#0 isEqualTo "") && !(_x#0 isEqualTo (binocular _target))) then {
						_myitems pushBack (_x select 0);
					};
				};
			}forEach(_x);
		}forEach(weaponsItems _target);
	}else{
		_myitems = (itemCargo _target) + (magazineCargo _target) + (backpackCargo _target);
		{
			{
				if(_x isEqualType "") then {
					if !(_x isEqualTo "") then {
						if(_forEachIndex isEqualTo 0) then {
							_myitems pushBack (_x call BIS_fnc_baseWeapon);
						}else{
							_myitems pushBack _x;
						};
					};
				};
				if(_x isEqualType []) then {
					if !((_x select 0) isEqualTo "") then {
						_myitems pushBack (_x select 0);
					};
				};
			}forEach(_x);
		}forEach(weaponsItemsCargo _target);
		{
			_x params ["_itemcls","_item"];
			_myitems = _myitems + (itemCargo _item) + (magazineCargo _item) + (backpackCargo _item) + (weaponCargo _item);
		}forEach(everyContainer _target);
	};
	if(isNil "_myitems") then {_myitems = []};
	_myitems = _myitems - OT_noCopyMags;
	_myitems
};

private _theseitems = _target call _allCargo;
if !(isNil "_theseitems") then {
	{
		private _cls = _x;
		if(_category isEqualTo "" || _cls in _categoryItems) then {
			// Modify the cls for TFAR items
			// Doesn't seem to do anything with modern TFAR, but I'll let it be just in case. ~ThomasAngel
			if (OT_hasTFAR) then {
				private _c = _cls splitString "_";
				if((_c select 0) == "tf") then { // I don't believe any modern TFAR classnames start with this...
					_cls = "tf";
					{
						if(_forEachIndex isEqualTo (count _c)-1) exitWith {};
						if(_forEachIndex != 0) then {
							_cls = format["%1_%2",_cls,_x];
						};
					}forEach(_c);
				};
			};

			_theseitems set [_forEachIndex, _cls];
		} else {
			_theseItems set [_forEachIndex, objNull];
		};
	}forEach(_theseitems);
	
	_theseitems = _theseitems - [objNull];
	_items = _theseitems call BIS_fnc_consolidateArray;
};
_items;
