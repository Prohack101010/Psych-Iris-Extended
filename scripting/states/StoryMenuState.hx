import scripting.HScriptStateHandler;

function onCreatePost()
{
    state.removeVirtualPad();
    state.addVirtualPad(HScriptStateHandler.dpadMode.get("FULL"), HScriptStateHandler.actionMode.get("A_B_X_Y"));
    game._virtualpad.y = -25;
}

function onCloseSubStatePost()
{
    state.removeVirtualPad();
    state.addVirtualPad(HScriptStateHandler.dpadMode.get("FULL"), HScriptStateHandler.actionMode.get("A_B_X_Y"));
    game._virtualpad.y = -25;
}