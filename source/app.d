/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
import std.stdio;
import reflet.core;

void main() {
    try {
        startup();
    }
    catch (Exception e) {
        writeln(e.msg);
        foreach (trace; e.info) {
            writeln("at: ", trace);
        }
    }
}
