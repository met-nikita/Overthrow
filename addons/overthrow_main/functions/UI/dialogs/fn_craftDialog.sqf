closeDialog 0;
createDialog "OT_dialog_craft";

{
    _x params ["_cls","_recipe","_qty"];
    (_cls call OT_fnc_getClassDisplayInfo) params ["_pic", "_name"];
    private _idx = lbAdd [1500,format["%1 x %2",_qty,_name]];
    lbSetPicture [1500,_idx,_pic];
    lbSetData [1500,_idx,format["%1-%2",_cls,_qty]];
}forEach(OT_craftableItems);
