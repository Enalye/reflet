/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module reflet.script.loader;

import grimoire;

import reflet.script.graphics, reflet.script.input;

private GrModuleLoader[] _libLoaders = [
    &loadGraphicsLibrary, &loadInputLibrary
];

/// Loads all sub libraries
GrLibrary loadBrumeLibrary() {
    GrLibrary library = new GrLibrary(1);
    foreach (GrModuleLoader loader; _libLoaders) {
        library.addModule(loader);
    }
    return library;
}
