/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module reflet.script.input;

import grimoire;
import reflet.constants, reflet.core;

void loadInputLibrary(GrModule library) {
    GrType keyType = library.addEnum("Key", grNativeEnum!Key);
    GrType btnType = library.addEnum("Button", grNativeEnum!Button);

    library.addFunction(&_getMouse, "getMouse", [], [grInt, grInt]);
    library.addFunction(&_getMouseX, "getMouseX", [], [grInt]);
    library.addFunction(&_getMouseY, "getMouseY", [], [grInt]);

    library.addFunction(&_isDown_key, "isDown", [keyType], [grBool]);
    library.addFunction(&_isDown_btn, "isDown", [btnType], [grBool]);

    library.addFunction(&_isUp_key, "isUp", [keyType], [grBool]);
    library.addFunction(&_isUp_btn, "isUp", [btnType], [grBool]);

    library.addFunction(&_isHeld_key, "isHeld", [keyType], [grBool]);
    library.addFunction(&_isHeld_btn, "isHeld", [btnType], [grBool]);

}

private void _isDown_key(GrCall call) {

    call.setBool((getInputState(call.getEnum!Key(0)) & 0b11) == 0b11);
}

private void _isDown_btn(GrCall call) {
    call.setBool((getInputState(call.getEnum!Button(0)) & 0b11) == 0b11);
}

private void _isUp_key(GrCall call) {
    call.setBool((getInputState(call.getEnum!Key(0)) & 0b11) == 0b10);
}

private void _isUp_btn(GrCall call) {
    call.setBool((getInputState(call.getEnum!Button(0)) & 0b11) == 0b10);
}

private void _isHeld_key(GrCall call) {
    call.setBool((getInputState(call.getEnum!Key(0)) & 0b1) > 0);
}

private void _isHeld_btn(GrCall call) {
    call.setBool((getInputState(call.getEnum!Button(0)) & 0b1) > 0);
}

private void _getMouse(GrCall call) {
    call.setInt(getMouseX());
    call.setInt(getMouseY());
}

private void _getMouseX(GrCall call) {
    call.setInt(getMouseX());
}

private void _getMouseY(GrCall call) {
    call.setInt(getMouseY());
}
