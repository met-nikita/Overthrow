private _index = lbCurSel 1500;
private _id = lbData [1500,_index];
_s = _id splitString "-";
_s params ["_cls","_qty"];
_qty = parseNumber _qty;
_def = [];
{
    _x params ["_c","_r","_q"];
    if(_cls == _c && _q isEqualTo _qty) exitWith {_def = _x};
}forEach(OT_craftableItems);

if(count _def > 0) then {
    private _err = false;
    _def params ["_cls","_recipe","_qty"];

    _container = nearestObject [player, OT_item_Storage];
    if !(isNull _container) then {
        if(_container distance player > 20) exitWith {"You need to be within 20m of an ammobox to craft" call OT_fnc_notifyMinor};
        _stock = _container call OT_fnc_unitStock;

        private _itemName = _cls call OT_fnc_getClassDisplayName;

        {
            _x params ["_needed","_qtyneeded"];
            _good = false;
            {
                _x params ["_c","_amt"];
                if(_c isEqualTo _needed) exitWith {
                    if(_amt >= _qtyneeded) then {
                        _good = true;
                    };
                };
                if(_c isKindOf [_needed,configFile >> "CfgMagazines"]) exitWith {
                    if(_amt >= _qtyneeded) then {
                        _good = true;
                    };
                };
                if(_c isKindOf [_needed,configFile >> "CfgWeapons"]) exitWith {
                    if(_amt >= _qtyneeded) then {
                        _good = true;
                    };
                };
            }forEach(_stock);

            if !(_good) exitWith {_err = true;"Required ingredients not in closest ammobox" call OT_fnc_notifyMinor};
        }forEach(_recipe);

        if !(_err) then {
            {
                _x params ["_needed","_qtyneeded"];
                {
                    _x params ["_c","_amt"];
                    if(_c isKindOf [_needed,configFile >> "CfgMagazines"]) exitWith {
                        [_container, _c, _qtyneeded] call CBA_fnc_removeMagazineCargo;
                    };
                    if(_c isKindOf [_needed,configFile >> "CfgWeapons"]) exitWith {
                        [_container, _c, _qtyneeded] call CBA_fnc_removeItemCargo;
                    };
                }forEach(_stock);
            }forEach(_recipe);

            _container addItemCargoGlobal [_cls, _qty];

            playSound "3DEN_notificationDefault";
            format["%1 x %2 added to closest ammobox",_qty,_itemName] call OT_fnc_notifyMinor;
        };
    };
};
