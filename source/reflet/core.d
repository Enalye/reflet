/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module reflet.core;

import std.stdio;
import std.string;
import std.exception;
import std.datetime.systime;
import core.thread;
import std.algorithm.comparison : clamp;

version (linux) {
    import core.sys.posix.unistd;
    import core.sys.posix.signal;
}
version (Windows) {
    import core.stdc.signal;
}

import bindbc.sdl;
import grimoire;

import reflet.constants, reflet.script, reflet.font, reflet.image;

/// Liste des touches du clavier.
enum KeyButton {
    unknown = SDL_SCANCODE_UNKNOWN,
    a = SDL_SCANCODE_A,
    b = SDL_SCANCODE_B,
    c = SDL_SCANCODE_C,
    d = SDL_SCANCODE_D,
    e = SDL_SCANCODE_E,
    f = SDL_SCANCODE_F,
    g = SDL_SCANCODE_G,
    h = SDL_SCANCODE_H,
    i = SDL_SCANCODE_I,
    j = SDL_SCANCODE_J,
    k = SDL_SCANCODE_K,
    l = SDL_SCANCODE_L,
    m = SDL_SCANCODE_M,
    n = SDL_SCANCODE_N,
    o = SDL_SCANCODE_O,
    p = SDL_SCANCODE_P,
    q = SDL_SCANCODE_Q,
    r = SDL_SCANCODE_R,
    s = SDL_SCANCODE_S,
    t = SDL_SCANCODE_T,
    u = SDL_SCANCODE_U,
    v = SDL_SCANCODE_V,
    w = SDL_SCANCODE_W,
    x = SDL_SCANCODE_X,
    y = SDL_SCANCODE_Y,
    z = SDL_SCANCODE_Z,
    alpha1 = SDL_SCANCODE_1,
    alpha2 = SDL_SCANCODE_2,
    alpha3 = SDL_SCANCODE_3,
    alpha4 = SDL_SCANCODE_4,
    alpha5 = SDL_SCANCODE_5,
    alpha6 = SDL_SCANCODE_6,
    alpha7 = SDL_SCANCODE_7,
    alpha8 = SDL_SCANCODE_8,
    alpha9 = SDL_SCANCODE_9,
    alpha0 = SDL_SCANCODE_0,
    enter = SDL_SCANCODE_RETURN,
    escape = SDL_SCANCODE_ESCAPE,
    backspace = SDL_SCANCODE_BACKSPACE,
    tab = SDL_SCANCODE_TAB,
    space = SDL_SCANCODE_SPACE,
    minus = SDL_SCANCODE_MINUS,
    equals = SDL_SCANCODE_EQUALS,
    leftBracket = SDL_SCANCODE_LEFTBRACKET,
    rightBracket = SDL_SCANCODE_RIGHTBRACKET,
    backslash = SDL_SCANCODE_BACKSLASH,
    nonushash = SDL_SCANCODE_NONUSHASH,
    semicolon = SDL_SCANCODE_SEMICOLON,
    apostrophe = SDL_SCANCODE_APOSTROPHE,
    grave = SDL_SCANCODE_GRAVE,
    comma = SDL_SCANCODE_COMMA,
    period = SDL_SCANCODE_PERIOD,
    slash = SDL_SCANCODE_SLASH,
    capslock = SDL_SCANCODE_CAPSLOCK,
    f1 = SDL_SCANCODE_F1,
    f2 = SDL_SCANCODE_F2,
    f3 = SDL_SCANCODE_F3,
    f4 = SDL_SCANCODE_F4,
    f5 = SDL_SCANCODE_F5,
    f6 = SDL_SCANCODE_F6,
    f7 = SDL_SCANCODE_F7,
    f8 = SDL_SCANCODE_F8,
    f9 = SDL_SCANCODE_F9,
    f10 = SDL_SCANCODE_F10,
    f11 = SDL_SCANCODE_F11,
    f12 = SDL_SCANCODE_F12,
    printScreen = SDL_SCANCODE_PRINTSCREEN,
    scrollLock = SDL_SCANCODE_SCROLLLOCK,
    pause = SDL_SCANCODE_PAUSE,
    insert = SDL_SCANCODE_INSERT,
    home = SDL_SCANCODE_HOME,
    pageup = SDL_SCANCODE_PAGEUP,
    remove = SDL_SCANCODE_DELETE,
    end = SDL_SCANCODE_END,
    pagedown = SDL_SCANCODE_PAGEDOWN,
    right = SDL_SCANCODE_RIGHT,
    left = SDL_SCANCODE_LEFT,
    down = SDL_SCANCODE_DOWN,
    up = SDL_SCANCODE_UP,
    numLockclear = SDL_SCANCODE_NUMLOCKCLEAR,
    numDivide = SDL_SCANCODE_KP_DIVIDE,
    numMultiply = SDL_SCANCODE_KP_MULTIPLY,
    numMinus = SDL_SCANCODE_KP_MINUS,
    numPlus = SDL_SCANCODE_KP_PLUS,
    numEnter = SDL_SCANCODE_KP_ENTER,
    num1 = SDL_SCANCODE_KP_1,
    num2 = SDL_SCANCODE_KP_2,
    num3 = SDL_SCANCODE_KP_3,
    num4 = SDL_SCANCODE_KP_4,
    num5 = SDL_SCANCODE_KP_5,
    num6 = SDL_SCANCODE_KP_6,
    num7 = SDL_SCANCODE_KP_7,
    num8 = SDL_SCANCODE_KP_8,
    num9 = SDL_SCANCODE_KP_9,
    num0 = SDL_SCANCODE_KP_0,
    numPeriod = SDL_SCANCODE_KP_PERIOD,
    nonusBackslash = SDL_SCANCODE_NONUSBACKSLASH,
    application = SDL_SCANCODE_APPLICATION,
    power = SDL_SCANCODE_POWER,
    numEquals = SDL_SCANCODE_KP_EQUALS,
    f13 = SDL_SCANCODE_F13,
    f14 = SDL_SCANCODE_F14,
    f15 = SDL_SCANCODE_F15,
    f16 = SDL_SCANCODE_F16,
    f17 = SDL_SCANCODE_F17,
    f18 = SDL_SCANCODE_F18,
    f19 = SDL_SCANCODE_F19,
    f20 = SDL_SCANCODE_F20,
    f21 = SDL_SCANCODE_F21,
    f22 = SDL_SCANCODE_F22,
    f23 = SDL_SCANCODE_F23,
    f24 = SDL_SCANCODE_F24,
    execute = SDL_SCANCODE_EXECUTE,
    help = SDL_SCANCODE_HELP,
    menu = SDL_SCANCODE_MENU,
    select = SDL_SCANCODE_SELECT,
    stop = SDL_SCANCODE_STOP,
    again = SDL_SCANCODE_AGAIN,
    undo = SDL_SCANCODE_UNDO,
    cut = SDL_SCANCODE_CUT,
    copy = SDL_SCANCODE_COPY,
    paste = SDL_SCANCODE_PASTE,
    find = SDL_SCANCODE_FIND,
    mute = SDL_SCANCODE_MUTE,
    volumeUp = SDL_SCANCODE_VOLUMEUP,
    volumeDown = SDL_SCANCODE_VOLUMEDOWN,
    numComma = SDL_SCANCODE_KP_COMMA,
    numEqualsAs400 = SDL_SCANCODE_KP_EQUALSAS400,
    international1 = SDL_SCANCODE_INTERNATIONAL1,
    international2 = SDL_SCANCODE_INTERNATIONAL2,
    international3 = SDL_SCANCODE_INTERNATIONAL3,
    international4 = SDL_SCANCODE_INTERNATIONAL4,
    international5 = SDL_SCANCODE_INTERNATIONAL5,
    international6 = SDL_SCANCODE_INTERNATIONAL6,
    international7 = SDL_SCANCODE_INTERNATIONAL7,
    international8 = SDL_SCANCODE_INTERNATIONAL8,
    international9 = SDL_SCANCODE_INTERNATIONAL9,
    lang1 = SDL_SCANCODE_LANG1,
    lang2 = SDL_SCANCODE_LANG2,
    lang3 = SDL_SCANCODE_LANG3,
    lang4 = SDL_SCANCODE_LANG4,
    lang5 = SDL_SCANCODE_LANG5,
    lang6 = SDL_SCANCODE_LANG6,
    lang7 = SDL_SCANCODE_LANG7,
    lang8 = SDL_SCANCODE_LANG8,
    lang9 = SDL_SCANCODE_LANG9,
    alterase = SDL_SCANCODE_ALTERASE,
    sysreq = SDL_SCANCODE_SYSREQ,
    cancel = SDL_SCANCODE_CANCEL,
    clear = SDL_SCANCODE_CLEAR,
    prior = SDL_SCANCODE_PRIOR,
    enter2 = SDL_SCANCODE_RETURN2,
    separator = SDL_SCANCODE_SEPARATOR,
    out_ = SDL_SCANCODE_OUT,
    oper = SDL_SCANCODE_OPER,
    clearAgain = SDL_SCANCODE_CLEARAGAIN,
    crsel = SDL_SCANCODE_CRSEL,
    exsel = SDL_SCANCODE_EXSEL,
    num00 = SDL_SCANCODE_KP_00,
    num000 = SDL_SCANCODE_KP_000,
    thousandSeparator = SDL_SCANCODE_THOUSANDSSEPARATOR,
    decimalSeparator = SDL_SCANCODE_DECIMALSEPARATOR,
    currencyUnit = SDL_SCANCODE_CURRENCYUNIT,
    currencySubunit = SDL_SCANCODE_CURRENCYSUBUNIT,
    numLeftParenthesis = SDL_SCANCODE_KP_LEFTPAREN,
    numRightParenthesis = SDL_SCANCODE_KP_RIGHTPAREN,
    numLeftBrace = SDL_SCANCODE_KP_LEFTBRACE,
    numRightBrace = SDL_SCANCODE_KP_RIGHTBRACE,
    numTab = SDL_SCANCODE_KP_TAB,
    numBackspace = SDL_SCANCODE_KP_BACKSPACE,
    numA = SDL_SCANCODE_KP_A,
    numB = SDL_SCANCODE_KP_B,
    numC = SDL_SCANCODE_KP_C,
    numD = SDL_SCANCODE_KP_D,
    numE = SDL_SCANCODE_KP_E,
    numF = SDL_SCANCODE_KP_F,
    numXor = SDL_SCANCODE_KP_XOR,
    numPower = SDL_SCANCODE_KP_POWER,
    numPercent = SDL_SCANCODE_KP_PERCENT,
    numLess = SDL_SCANCODE_KP_LESS,
    numGreater = SDL_SCANCODE_KP_GREATER,
    numAmpersand = SDL_SCANCODE_KP_AMPERSAND,
    numDblAmpersand = SDL_SCANCODE_KP_DBLAMPERSAND,
    numVerticalBar = SDL_SCANCODE_KP_VERTICALBAR,
    numDblVerticalBar = SDL_SCANCODE_KP_DBLVERTICALBAR,
    numColon = SDL_SCANCODE_KP_COLON,
    numHash = SDL_SCANCODE_KP_HASH,
    numSpace = SDL_SCANCODE_KP_SPACE,
    numAt = SDL_SCANCODE_KP_AT,
    numExclam = SDL_SCANCODE_KP_EXCLAM,
    numMemStore = SDL_SCANCODE_KP_MEMSTORE,
    numMemRecall = SDL_SCANCODE_KP_MEMRECALL,
    numMemClear = SDL_SCANCODE_KP_MEMCLEAR,
    numMemAdd = SDL_SCANCODE_KP_MEMADD,
    numMemSubtract = SDL_SCANCODE_KP_MEMSUBTRACT,
    numMemMultiply = SDL_SCANCODE_KP_MEMMULTIPLY,
    numMemDivide = SDL_SCANCODE_KP_MEMDIVIDE,
    numPlusMinus = SDL_SCANCODE_KP_PLUSMINUS,
    numClear = SDL_SCANCODE_KP_CLEAR,
    numClearEntry = SDL_SCANCODE_KP_CLEARENTRY,
    numBinary = SDL_SCANCODE_KP_BINARY,
    numOctal = SDL_SCANCODE_KP_OCTAL,
    numDecimal = SDL_SCANCODE_KP_DECIMAL,
    numHexadecimal = SDL_SCANCODE_KP_HEXADECIMAL,
    leftControl = SDL_SCANCODE_LCTRL,
    leftShift = SDL_SCANCODE_LSHIFT,
    leftAlt = SDL_SCANCODE_LALT,
    leftGUI = SDL_SCANCODE_LGUI,
    rightControl = SDL_SCANCODE_RCTRL,
    rightShift = SDL_SCANCODE_RSHIFT,
    rightAlt = SDL_SCANCODE_RALT,
    rightGUI = SDL_SCANCODE_RGUI,
    mode = SDL_SCANCODE_MODE,
    audioNext = SDL_SCANCODE_AUDIONEXT,
    audioPrev = SDL_SCANCODE_AUDIOPREV,
    audioStop = SDL_SCANCODE_AUDIOSTOP,
    audioPlay = SDL_SCANCODE_AUDIOPLAY,
    audioMute = SDL_SCANCODE_AUDIOMUTE,
    mediaSelect = SDL_SCANCODE_MEDIASELECT,
    www = SDL_SCANCODE_WWW,
    mail = SDL_SCANCODE_MAIL,
    calculator = SDL_SCANCODE_CALCULATOR,
    computer = SDL_SCANCODE_COMPUTER,
    acSearch = SDL_SCANCODE_AC_SEARCH,
    acHome = SDL_SCANCODE_AC_HOME,
    acBack = SDL_SCANCODE_AC_BACK,
    acForward = SDL_SCANCODE_AC_FORWARD,
    acStop = SDL_SCANCODE_AC_STOP,
    acRefresh = SDL_SCANCODE_AC_REFRESH,
    acBookmarks = SDL_SCANCODE_AC_BOOKMARKS,
    brightnessDown = SDL_SCANCODE_BRIGHTNESSDOWN,
    brightnessUp = SDL_SCANCODE_BRIGHTNESSUP,
    displaysWitch = SDL_SCANCODE_DISPLAYSWITCH,
    kbdIllumToggle = SDL_SCANCODE_KBDILLUMTOGGLE,
    kbdIllumDown = SDL_SCANCODE_KBDILLUMDOWN,
    kbdIllumUp = SDL_SCANCODE_KBDILLUMUP,
    eject = SDL_SCANCODE_EJECT,
    sleep = SDL_SCANCODE_SLEEP,
    app1 = SDL_SCANCODE_APP1,
    app2 = SDL_SCANCODE_APP2
}

/// Liste des boutons de la manette.
enum ControllerButton {
    unknown = SDL_CONTROLLER_BUTTON_INVALID,
    a = SDL_CONTROLLER_BUTTON_A,
    b = SDL_CONTROLLER_BUTTON_B,
    x = SDL_CONTROLLER_BUTTON_X,
    y = SDL_CONTROLLER_BUTTON_Y,
    back = SDL_CONTROLLER_BUTTON_BACK,
    guide = SDL_CONTROLLER_BUTTON_GUIDE,
    start = SDL_CONTROLLER_BUTTON_START,
    leftStick = SDL_CONTROLLER_BUTTON_LEFTSTICK,
    rightStick = SDL_CONTROLLER_BUTTON_RIGHTSTICK,
    leftShoulder = SDL_CONTROLLER_BUTTON_LEFTSHOULDER,
    rightShoulder = SDL_CONTROLLER_BUTTON_RIGHTSHOULDER,
    up = SDL_CONTROLLER_BUTTON_DPAD_UP,
    down = SDL_CONTROLLER_BUTTON_DPAD_DOWN,
    left = SDL_CONTROLLER_BUTTON_DPAD_LEFT,
    right = SDL_CONTROLLER_BUTTON_DPAD_RIGHT
}

/// Liste des axes de la manette.
enum ControllerAxis {
    unknown = SDL_CONTROLLER_AXIS_INVALID,
    leftX = SDL_CONTROLLER_AXIS_LEFTX,
    leftY = SDL_CONTROLLER_AXIS_LEFTY,
    rightX = SDL_CONTROLLER_AXIS_RIGHTX,
    rightY = SDL_CONTROLLER_AXIS_RIGHTY,
    leftTrigger = SDL_CONTROLLER_AXIS_TRIGGERLEFT,
    rightTrigger = SDL_CONTROLLER_AXIS_TRIGGERRIGHT
}

private struct Controller {
    SDL_GameController* sdlController;
    SDL_Joystick* sdlJoystick;
    int index, joystickId;
}

private {
    shared bool _isRunning = false;
    long _tickStartFrame;

    // Rendu
    SDL_Window* _window;
    SDL_Renderer* _renderer;
    SDL_Texture* _screenBuffer;
    SDL_Surface* _icon;
    ubyte[CANVAS_HEIGHT][CANVAS_WIDTH] _screen;

    uint[16] _palette = [
        0x000000, 0x2b335f, 0x7e2072, 0x19959c, 0x8b4852, 0x395c98, 0xa9c1ff,
        0xeeeeee, 0xd4186c, 0xd38441, 0xe9c35b, 0x70c6a9, 0x7696de, 0xa3a3a3,
        0xff9798, 0xedc7b0
    ];

    /*[
        0x000000,
        0x1D2B53,
        0x7E2553,
        0x008751,
        0xAB5236,
        0x5F574F,
        0xC2C3C7,
        0xFFF1E8,
        0xFF004D,
        0xFFA300,
        0xFFEC27,
        0x00E436,
        0x29ADFF,
        0x83769C,
        0xFF77A8,
        0xFFCCAA
    ];*/

    int _clipX1, _clipY1, _clipX2 = CANVAS_WIDTH - 1, _clipY2 = CANVAS_HEIGHT - 1;

    // Entrées
    Controller[] _controllers;
    int _mouseX, _mouseY;
    bool[KeyButton.max + 1] _keys1, _keys2;
    bool[ControllerButton.max + 1] _buttons1, _buttons2;
    float[ControllerAxis.max + 1] _axis = 0f;

    // Programme
    GrEngine _engine;
}

/// Vérifie if la touche associée à l'id est pressée. \
/// Ne remet pas la touche à zéro.
bool isButtonDown(KeyButton button) {
    return _keys1[button];
}

/// Ditto
bool isButtonDown(ControllerButton button) {
    return _buttons1[button];
}

/// Vérifie if la touche associée à l'id est pressée. \
/// Remet la touche à zéro.
bool getButtonDown(KeyButton button) {
    const bool value = _keys2[button];
    _keys2[button] = false;
    return value;
}

/// Ditto
bool getButtonDown(ControllerButton button) {
    const bool value = _buttons2[button];
    _buttons2[button] = false;
    return value;
}

/// Retourne la valeur actuelle de l'axe.
float getAxis(ControllerAxis axis) {
    return _axis[axis];
}

/// Retourne la position de la souris.
int getMouseX() {
    return _mouseX;
}

///Ditto
int getMouseY() {
    return _mouseY;
}

/// Capture les interruptions.
private extern (C) void _signalHandler(int sig) nothrow @nogc @system {
    cast(void) sig;
    _isRunning = false;
}

/// Ouvre toutes les manettes connectées.
private void _openControllers() {
    foreach (index; 0 .. SDL_NumJoysticks())
        addController(index);
    SDL_GameControllerEventState(SDL_ENABLE);
}

/// Ferme toutes les manettes connectées.
private void _closeControllers() {
    foreach (ref controller; _controllers)
        SDL_GameControllerClose(controller.sdlController);
}

/// Enregistre les dispositions des manettes présentent dans un fichier. \
/// Se doit d'être dans un format valide.
void addControllerMappingsFromFile(string filePath) {
    import std.file : exists;

    if (!exists(filePath))
        throw new Exception("Could not find \'" ~ filePath ~ "\'.");
    if (-1 == SDL_GameControllerAddMappingsFromFile(toStringz(filePath)))
        throw new Exception("Invalid mapping file \'" ~ filePath ~ "\'.");
}

/// Enregistre une nouvelle disposition de manette. \
/// Se doit d'être dans un format valide.
void addControllerMapping(string mapping) {
    if (-1 == SDL_GameControllerAddMapping(toStringz(mapping)))
        throw new Exception("Invalid mapping.");
}

/// Essaie d'ajouter une nouvelle manette.
void addController(int index) {
    auto c = SDL_JoystickNameForIndex(index);
    auto d = fromStringz(c);

    if (!SDL_IsGameController(index)) {
        //writeln("The device is not recognised as a game controller.");
        auto stick = SDL_JoystickOpen(index);
        auto guid = SDL_JoystickGetGUID(stick);
        //writeln("The device guid is: ");
        //foreach (i; 0 .. 16)
        //    printf("%02x", guid.data[i]);
        //writeln("");
        return;
    }
    foreach (ref controller; _controllers) {
        if (controller.index == index) {
            //writeln("The controller is already open, aborted.");
            return;
        }
    }

    auto sdlController = SDL_GameControllerOpen(index);
    if (!sdlController) {
        //writeln("Could not connect the game controller.");
        return;
    }

    Controller controller;
    controller.sdlController = sdlController;
    controller.index = index;
    controller.sdlJoystick = SDL_GameControllerGetJoystick(controller.sdlController);
    controller.joystickId = SDL_JoystickInstanceID(controller.sdlJoystick);
    _controllers ~= controller;
}

/// Retire une manette connectée.
void removeController(int joystickId) {
    int index;
    bool isControllerPresent;
    foreach (ref controller; _controllers) {
        if (controller.joystickId == joystickId) {
            isControllerPresent = true;
            break;
        }
        index++;
    }

    if (!isControllerPresent)
        return;

    SDL_GameControllerClose(_controllers[index].sdlController);

    //Retire la manette de la liste.
    if (index + 1 == _controllers.length)
        _controllers.length--;
    else if (index == 0)
        _controllers = _controllers[1 .. $];
    else
        _controllers = _controllers[0 .. index] ~ _controllers[(index + 1) .. $];
}

/// Récupère les différents événements clavier et de la fenêtre.
private bool _fetchEvents() {
    SDL_Event event;

    if (!_isRunning) {
        _destroyWindow();
        return false;
    }

    while (SDL_PollEvent(&event)) {
        switch (event.type) {
        case SDL_QUIT:
            _isRunning = false;
            _destroyWindow();
            return false;
        case SDL_KEYDOWN:
            if (event.key.keysym.scancode >= _keys1.length)
                break;
            if (!event.key.repeat) {
                _keys1[event.key.keysym.scancode] = true;
                _keys2[event.key.keysym.scancode] = true;
            }
            break;
        case SDL_KEYUP:
            if (event.key.keysym.scancode >= _keys1.length)
                break;
            _keys1[event.key.keysym.scancode] = false;
            _keys2[event.key.keysym.scancode] = false;
            break;
        case SDL_CONTROLLERDEVICEADDED:
            addController(event.cdevice.which);
            break;
        case SDL_CONTROLLERDEVICEREMOVED:
            removeController(event.cdevice.which);
            break;
        case SDL_CONTROLLERDEVICEREMAPPED:
            break;
        case SDL_CONTROLLERAXISMOTION:
            if (event.caxis.axis >= 0 && event.caxis.axis <= ControllerAxis.max) {
                if (event.caxis.value < 0)
                    _axis[event.caxis.axis] = event.caxis.value / 32_768f;
                else
                    _axis[event.caxis.axis] = event.caxis.value / 32_767f;
            }
            break;
        case SDL_CONTROLLERBUTTONDOWN:
            if (event.cbutton.button <= ControllerButton.max) {
                _buttons1[event.cbutton.button] = true;
                _buttons2[event.cbutton.button] = true;
            }
            break;
        case SDL_CONTROLLERBUTTONUP:
            if (event.cbutton.button <= ControllerButton.max) {
                _buttons1[event.cbutton.button] = false;
                _buttons2[event.cbutton.button] = false;
            }
            break;
        default:
            break;
        }
    }

    SDL_GetGlobalMouseState(&_mouseX, &_mouseY);
    _mouseX /= CANVAS_SCALE;
    _mouseY /= CANVAS_SCALE;
    _mouseX = clamp(_mouseX, 0, CANVAS_WIDTH - 1);
    _mouseY = clamp(_mouseY, 0, CANVAS_HEIGHT - 1);

    return true;
}

/// Main application loop
void startup() {
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }
    _initWindow();

    signal(SIGINT, &_signalHandler);
    _isRunning = true;
    _openControllers();

    initFont();

    _tickStartFrame = Clock.currStdTime();

    // Script
    GrLibrary stdlib = grGetStandardLibrary();
    GrLibrary brumelib = loadBrumeLibrary();

    GrCompiler compiler = new GrCompiler;
    compiler.addLibrary(stdlib);
    compiler.addLibrary(brumelib);

    compiler.addFile("script/main.gr");
    GrBytecode bytecode = compiler.compile(GrOption.symbols, GrLocale.fr_FR);
    if (bytecode) {
        _engine = new GrEngine;
        _engine.addLibrary(stdlib);
        _engine.addLibrary(brumelib);
        _engine.load(bytecode);

        _engine.callEvent("app");
    }
    else {
        _engine = null;
        writeln(compiler.getError().prettify(GrLocale.fr_FR));
    }
    SDL_CaptureMouse(true);

    while (_fetchEvents()) {
        if (bytecode && getButtonDown(KeyButton.f5)) {
            _engine = new GrEngine;
            _engine.addLibrary(stdlib);
            _engine.addLibrary(brumelib);
            _engine.load(bytecode);

            _engine.callEvent("app");
        }
        else if (getButtonDown(KeyButton.f6)) {
            compiler = new GrCompiler;
            compiler.addLibrary(stdlib);
            compiler.addLibrary(brumelib);
            compiler.addFile("script/main.gr");

            bytecode = compiler.compile(GrOption.none, GrLocale.fr_FR);
            if (bytecode) {
                _engine = new GrEngine;
                _engine.addLibrary(stdlib);
                _engine.addLibrary(brumelib);
                _engine.load(bytecode);

                _engine.callEvent("app");
            }
            else {
                _engine = null;
                writeln(compiler.getError().prettify(GrLocale.fr_FR));
            }
        }

        if (_engine) {
            if (_engine.hasTasks)
                _engine.process();

            if (_engine.isPanicking()) {
                writeln("panique: " ~ _engine.panicMessage);
                foreach (trace; _engine.stackTraces) {
                    writeln("[", trace.pc, "] dans ", trace.name, " à ",
                        trace.file, "(", trace.line, ",", trace.column, ")");
                    _engine = null;
                }
            }
        }

        _renderWindow();

        long deltaTicks = Clock.currStdTime() - _tickStartFrame;
        if (deltaTicks < (10_000_000 / FRAME_RATE))
            Thread.sleep(dur!("hnsecs")((10_000_000 / FRAME_RATE) - deltaTicks));

        deltaTicks = Clock.currStdTime() - _tickStartFrame;
        _tickStartFrame = Clock.currStdTime();
    }
}

import core.sys.windows.windef;
import core.sys.windows.winuser;
import core.sys.windows.wingdi;

pragma(lib, "user32");

void _setWindowColorKey(SDL_Window* window) {
    SDL_SysWMinfo wmInfo;
    SDL_VERSION(&wmInfo.version_);
    SDL_GetWindowWMInfo(window, &wmInfo);
    HWND hWnd = wmInfo.info.win.window;
    SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd,
            GWL_EXSTYLE) | WS_EX_LAYERED | WS_EX_TRANSPARENT);

    uint colorKey = _palette[0];
    COLORREF winColor = RGB((colorKey & 0xff0000) >> 16, (colorKey & 0xff00) >> 8, colorKey & 0xff);
    SetLayeredWindowAttributes(hWnd, winColor, 0, LWA_COLORKEY);
}

/// Create the application window.
private void _initWindow() {
    enforce(SDL_Init(SDL_INIT_EVERYTHING) == 0,
        "la sdl n'a pas pu s'initialiser: " ~ fromStringz(SDL_GetError()));

    enforce(SDL_CreateWindowAndRenderer(WINDOW_WIDTH, WINDOW_HEIGHT,
            SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC | SDL_WINDOW_ALWAYS_ON_TOP | SDL_WINDOW_BORDERLESS,
            &_window, &_renderer) != -1, "l'initialization de la fenêtre a échouée");

    _screenBuffer = SDL_CreateTexture(_renderer, SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_STREAMING, CANVAS_WIDTH, CANVAS_HEIGHT);

    SDL_RenderSetLogicalSize(_renderer, CANVAS_WIDTH, CANVAS_HEIGHT);
    _setWindowColorKey(_window);

    setWindowTitle("Brume");
}

/// Cleanup the application window.
private void _destroyWindow() {
    _closeControllers();

    if (_screenBuffer !is null)
        SDL_DestroyTexture(_screenBuffer);

    if (_window)
        SDL_DestroyWindow(_window);

    if (_renderer)
        SDL_DestroyRenderer(_renderer);
}

/// Change the actual window title.
void setWindowTitle(string title) {
    SDL_SetWindowTitle(_window, toStringz(title));
}

/// Change the icon displayed.
/*void setWindowIcon(string path) {
    if (_icon) {
        SDL_FreeSurface(_icon);
        _icon = null;
    }
    _icon = IMG_Load(toStringz(path));

    SDL_SetWindowIcon(_window, _icon);
}*/

/// Render everything on screen.
private void _renderWindow() {
    uint* pixels;
    int pitch;
    if (SDL_LockTexture(_screenBuffer, null, cast(void**)&pixels, &pitch) == 0) {
        for (uint y; y < CANVAS_HEIGHT; ++y) {
            for (uint x; x < CANVAS_WIDTH; ++x) {
                ubyte colorId = _screen[x][y];
                pixels[y * CANVAS_WIDTH + x] = (_palette[colorId] << 8);
            }
        }
        SDL_UnlockTexture(_screenBuffer);
    }
    else {
        import std.stdio;

        writeln("erreur: ", fromStringz(SDL_GetError()));
    }

    SDL_Rect destRect = {0, 0, CANVAS_WIDTH, CANVAS_HEIGHT};
    SDL_RenderCopy(_renderer, _screenBuffer, null, &destRect);

    SDL_RenderPresent(_renderer);
}

void clipScreen(int x, int y, int w, int h) {
    import std.algorithm.comparison : min, max;

    _clipX1 = max(min(x, CANVAS_WIDTH - 1), 0);
    _clipY1 = max(min(y, CANVAS_HEIGHT - 1), 0);
    _clipX2 = max(min(x + w, CANVAS_WIDTH - 1), 0);
    _clipY2 = max(min(y + h, CANVAS_HEIGHT - 1), 0);

    if (_clipX1 > _clipX2) {
        const int tmp = _clipX2;
        _clipX2 = _clipX1;
        _clipX1 = tmp;
    }
    if (_clipY1 > _clipY2) {
        const int tmp = _clipY2;
        _clipY2 = _clipY1;
        _clipY1 = tmp;
    }
}

void clearScreen(int c) {
    if (c < 0 || c >= PALETTE_SIZE)
        return;
    for (int y = _clipY1; y <= _clipY2; ++y) {
        for (int x = _clipX1; x <= _clipX2; ++x) {
            _screen[x][y] = cast(ubyte) c;
        }
    }
}

void drawPixel(int x, int y, int c) {
    if (x < _clipX1 || y < _clipY1 || x > _clipX2 || y >= _clipY2 || c < 0 || c >= PALETTE_SIZE)
        return;
    _screen[x][y] = cast(ubyte) c;
}

private void _drawPixel(int x, int y, int c) {
    if (x < _clipX1 || y < _clipY1 || x > _clipX2 || y >= _clipY2)
        return;
    _screen[x][y] = cast(ubyte) c;
}

void drawRect(int x1, int y1, int x2, int y2, int c) {
    import std.algorithm.comparison : min, max;

    if (c < 0 || c >= PALETTE_SIZE)
        return;
    x1 = max(x1, _clipX1);
    y1 = max(y1, _clipY1);
    x2 = min(x2, _clipX2);
    y2 = min(y2, _clipY2);

    for (int y = y1; y <= y2; ++y) {
        _screen[x1][y] = cast(ubyte) c;
        _screen[x2][y] = cast(ubyte) c;
    }
    for (int x = x1; x <= x2; ++x) {
        _screen[x][y1] = cast(ubyte) c;
        _screen[x][y2] = cast(ubyte) c;
    }
}

void drawFilledRect(int x1, int y1, int x2, int y2, int c) {
    import std.algorithm.comparison : min, max;

    if (c < 0 || c >= PALETTE_SIZE)
        return;
    x1 = max(x1, _clipX1);
    y1 = max(y1, _clipY1);
    x2 = min(x2, _clipX2);
    y2 = min(y2, _clipY2);

    for (int y = y1; y <= y2; ++y) {
        for (int x = x1; x <= x2; ++x) {
            _screen[x][y] = cast(ubyte) c;
        }
    }
}

void drawCircle(int xc, int yc, int r, int c) {
    import std.algorithm.comparison : min, max;

    if (c < 0 || c >= PALETTE_SIZE)
        return;

    int x = 0;
    int y = r;
    int d = r - 1;

    while (y >= x) {
        drawPixel(xc + x, yc + y, c);
        drawPixel(xc + y, yc + x, c);
        drawPixel(xc - x, yc + y, c);
        drawPixel(xc - y, yc + x, c);
        drawPixel(xc + x, yc - y, c);
        drawPixel(xc + y, yc - x, c);
        drawPixel(xc - x, yc - y, c);
        drawPixel(xc - y, yc - x, c);

        if (d >= 2 * x) {
            d -= 2 * x + 1;
            x++;
        }
        else if (d < 2 * (r - y)) {
            d += 2 * y - 1;
            y--;
        }
        else {
            d += 2 * (y - x - 1);
            y--;
            x++;
        }
    }
}

void drawFilledCircle(int xc, int yc, int r, int c) {
    import std.algorithm.comparison : min, max;

    if (c < 0 || c >= PALETTE_SIZE)
        return;

    int x = 0;
    int y = r;
    int d = r - 1;

    void drawColumn(int x, int y1, int y2, int c) {
        for (; y1 <= y2; ++y1) {
            drawPixel(x, y1, c);
        }
    }

    while (y >= x) {
        drawColumn(xc + x, yc - y, yc + y, c);
        drawColumn(xc + y, yc - x, yc + x, c);
        drawColumn(xc - x, yc - y, yc + y, c);
        drawColumn(xc - y, yc - x, yc + x, c);

        if (d >= 2 * x) {
            d -= 2 * x + 1;
            x++;
        }
        else if (d < 2 * (r - y)) {
            d += 2 * y - 1;
            y--;
        }
        else {
            d += 2 * (y - x - 1);
            y--;
            x++;
        }
    }
}

void drawLine(int x1, int y1, int x2, int y2, int c) {
    int dx = x2 - x1;
    int dy = y2 - y1;

    if (dx == 0) {
        if (dy > 0) {
            for (; y1 <= y2; ++y1) {
                _drawPixel(x1, y1, c);
            }
        }
        else {
            for (; y2 <= y1; ++y2) {
                _drawPixel(x1, y2, c);
            }
        }
    }
    else if (dy == 0) {
        if (dx > 0) {
            for (; x1 <= x2; ++x1) {
                _drawPixel(x1, y1, c);
            }
        }
        else {
            for (; x2 <= x1; ++x2) {
                _drawPixel(x2, y1, c);
            }
        }
    }
    else if (dx != 0) {
        if (dx > 0) {
            if (dy != 0) {
                if (dy > 0) {
                    // vecteur oblique dans le 1er cadran
                    if (dx >= dy) {
                        // vecteur diagonal ou oblique proche de l’horizontale, dans le 1er octant
                        int e;
                        dx = (e = dx) * 2;
                        dy = dy * 2; // e est positif
                        for (;;) { // déplacements horizontaux
                            _drawPixel(x1, y1, c);
                            if ((x1 = x1 + 1) == x2)
                                break;
                            if ((e = e - dy) < 0) {
                                y1 = y1 + 1; // déplacement diagonal
                                e = e + dx;
                            }
                        }
                    }
                    else {
                        // vecteur oblique proche de la verticale, dans le 2d octant
                        int e;
                        dy = (e = dy) * 2;
                        dx = dx * 2; // e est positif
                        for (;;) { // déplacements verticaux
                            _drawPixel(x1, y1, c);
                            if ((y1 = y1 + 1) == y2)
                                break;
                            if ((e == e - dx) < 0) {
                                x1 = x1 + 1; // déplacement diagonal
                                e = e + dy;
                            }
                        }
                    }

                }
                else { // dy < 0 (et dx > 0)
                    // vecteur oblique dans le 4e cadran
                    if (dx >= -dy) {
                        // vecteur diagonal ou oblique proche de l’horizontale, dans le 8e octant
                        int e;
                        dx = (e = dx) * 2;
                        dy = dy * 2; // e est positif
                        for (;;) { // déplacements horizontaux
                            _drawPixel(x1, y1, c);
                            if ((x1 = x1 + 1) == x2)
                                break;
                            if ((e = e + dy) < 0) {
                                y1 = y1 - 1; // déplacement diagonal
                                e = e + dx;
                            }
                        }
                    }
                    else { // vecteur oblique proche de la verticale, dans le 7e octant
                        int e;
                        dy = (e = dy) * 2;
                        dx = dx * 2; // e est négatif
                        for (;;) { // déplacements verticaux
                            _drawPixel(x1, y1, c);
                            if ((y1 = y1 - 1) == y2)
                                break;
                            if ((e = e + dx) > 0) {
                                x1 = x1 + 1; // déplacement diagonal
                                e = e + dy;
                            }
                        }
                    }

                }
            }
            else { // dy == 0 (et dx > 0)
                // vecteur horizontal vers la droite
                do {
                    _drawPixel(x1, y1, c);
                }
                while ((x1 = x1 + 1) == x2);

            }
        }
        else { // dx < 0
            if (dy != 0) {
                if (dy > 0) {
                    // vecteur oblique dans le 2d cadran

                    if (-dx >= dy) {
                        // vecteur diagonal ou oblique proche de l’horizontale, dans le 4e octant
                        int e;
                        dx = (e = dx) * 2;
                        dy = dy * 2; // e est négatif
                        for (;;) { // déplacements horizontaux
                            drawPixel(x1, y1, c);
                            if ((x1 = x1 - 1) == x2)
                                break;
                            if ((e = e + dy) >= 0) {
                                y1 = y1 + 1; // déplacement diagonal
                                e = e + dx;
                            }
                        }
                    }
                    else {
                        // vecteur oblique proche de la verticale, dans le 3e octant
                        int e;
                        dy = (e = dy) * 2;
                        dx = dx * 2; // e est positif
                        for (;;) { // déplacements verticaux
                            drawPixel(x1, y1, c);
                            if ((y1 = y1 + 1) == y2)
                                break;
                            if ((e = e + dx) <= 0) {
                                x1 = x1 - 1; // déplacement diagonal
                                e = e + dy;
                            }
                        }
                    }

                }
                else { // dy < 0 (et dx < 0)
                    // vecteur oblique dans le 3e cadran

                    if (dx <= dy) {
                        // vecteur diagonal ou oblique proche de l’horizontale, dans le 5e octant
                        int e;
                        dx = (e = dx) * 2;
                        dy = dy * 2; // e est négatif
                        for (;;) { // déplacements horizontaux
                            drawPixel(x1, y1, c);
                            if ((x1 = x1 - 1) == x2)
                                break;
                            if ((e = e - dy) >= 0) {
                                y1 = y1 - 1; // déplacement diagonal
                                e = e + dx;
                            }
                        }
                    }
                    else { // vecteur oblique proche de la verticale, dans le 6e octant
                        int e;
                        dy = (e = dy) * 2;
                        dx = dx * 2; // e est négatif
                        for (;;) { // déplacements verticaux
                            drawPixel(x1, y1, c);
                            if ((y1 = y1 - 1) == y2)
                                break;
                            if ((e = e - dx) >= 0) {
                                x1 = x1 - 1; // déplacement diagonal
                                e = e + dy;
                            }
                        }
                    }

                }
            }
            else { // dy = 0 (et dx < 0)

                // vecteur horizontal vers la gauche
                do {
                    drawPixel(x1, y1, c);
                }
                while ((x1 = x1 - 1) == x2);

            }
        }
    }
    else {
        if (dy != 0) {
            if (dy > 0) {
                // vecteur vertical croissant
                do {
                    drawPixel(x1, y1, c);
                }
                while ((y1 = y1 + 1) == y2);

            }
            else {
                // vecteur vertical décroissant
                do {
                    drawPixel(x1, y1, c);
                }
                while ((y1 = y1 - 1) == y2);

            }
        }
    }
}

void drawFilledTriangle(int x1, int y1, int x2, int y2, int x3, int y3, int c) {
    import std.algorithm.comparison : min, max;

    if (c < 0 || c >= PALETTE_SIZE)
        return;

    int yMin = min(y1, y2, y3);
    int yMax = max(y1, y2, y3);

    int[2][] line = _scanLine(x1, y1, x2, y2) ~ _scanLine(x2, y2, x3, y3) ~ _scanLine(x3,
        y3, x1, y1);
    for (int y = yMin; y <= yMax; ++y) {
        int xMin = int.max, xMax = int.min;
        foreach (ref int[2] p; line) {
            if (p[1] == y) {
                if (xMin > p[0])
                    xMin = p[0];
                if (xMax < p[0])
                    xMax = p[0];
            }
        }
        for (; xMin <= xMax; ++xMin) {
            _drawPixel(xMin, y, c);
        }
    }
}

void drawTriangle(int x1, int y1, int x2, int y2, int x3, int y3, int c) {
    if (c < 0 || c >= PALETTE_SIZE)
        return;

    drawLine(x1, y1, x2, y2, c);
    drawLine(x2, y2, x3, y3, c);
    drawLine(x3, y3, x1, y1, c);
}

private int[2][] _scanLine(int x1, int y1, int x2, int y2) {
    int[2][] result;
    int dx = x2 - x1;
    int dy = y2 - y1;

    if (dx == 0) {
        if (dy > 0) {
            for (; y1 <= y2; ++y1) {
                result ~= [x1, y1];
            }
        }
        else {
            for (; y2 <= y1; ++y2) {
                result ~= [x1, y2];
            }
        }
    }
    else if (dy == 0) {
        if (dx > 0) {
            for (; x1 <= x2; ++x1) {
                result ~= [x1, y1];
            }
        }
        else {
            for (; x2 <= x1; ++x2) {
                result ~= [x2, y1];
            }
        }
    }
    else if (dx != 0) {
        if (dx > 0) {
            if (dy != 0) {
                if (dy > 0) {
                    // vecteur oblique dans le 1er cadran
                    if (dx >= dy) {
                        // vecteur diagonal ou oblique proche de l’horizontale, dans le 1er octant
                        int e;
                        dx = (e = dx) * 2;
                        dy = dy * 2; // e est positif
                        for (;;) { // déplacements horizontaux
                            result ~= [x1, y1];
                            if ((x1 = x1 + 1) == x2)
                                break;
                            if ((e = e - dy) < 0) {
                                y1 = y1 + 1; // déplacement diagonal
                                e = e + dx;
                            }
                        }
                    }
                    else {
                        // vecteur oblique proche de la verticale, dans le 2d octant
                        int e;
                        dy = (e = dy) * 2;
                        dx = dx * 2; // e est positif
                        for (;;) { // déplacements verticaux
                            result ~= [x1, y1];
                            if ((y1 = y1 + 1) == y2)
                                break;
                            if ((e == e - dx) < 0) {
                                x1 = x1 + 1; // déplacement diagonal
                                e = e + dy;
                            }
                        }
                    }

                }
                else { // dy < 0 (et dx > 0)
                    // vecteur oblique dans le 4e cadran
                    if (dx >= -dy) {
                        // vecteur diagonal ou oblique proche de l’horizontale, dans le 8e octant
                        int e;
                        dx = (e = dx) * 2;
                        dy = dy * 2; // e est positif
                        for (;;) { // déplacements horizontaux
                            result ~= [x1, y1];
                            if ((x1 = x1 + 1) == x2)
                                break;
                            if ((e = e + dy) < 0) {
                                y1 = y1 - 1; // déplacement diagonal
                                e = e + dx;
                            }
                        }
                    }
                    else { // vecteur oblique proche de la verticale, dans le 7e octant
                        int e;
                        dy = (e = dy) * 2;
                        dx = dx * 2; // e est négatif
                        for (;;) { // déplacements verticaux
                            result ~= [x1, y1];
                            if ((y1 = y1 - 1) == y2)
                                break;
                            if ((e = e + dx) > 0) {
                                x1 = x1 + 1; // déplacement diagonal
                                e = e + dy;
                            }
                        }
                    }

                }
            }
            else { // dy == 0 (et dx > 0)
                // vecteur horizontal vers la droite
                do {
                    result ~= [x1, y1];
                }
                while ((x1 = x1 + 1) == x2);

            }
        }
        else { // dx < 0
            if (dy != 0) {
                if (dy > 0) {
                    // vecteur oblique dans le 2d cadran

                    if (-dx >= dy) {
                        // vecteur diagonal ou oblique proche de l’horizontale, dans le 4e octant
                        int e;
                        dx = (e = dx) * 2;
                        dy = dy * 2; // e est négatif
                        for (;;) { // déplacements horizontaux
                            result ~= [x1, y1];
                            if ((x1 = x1 - 1) == x2)
                                break;
                            if ((e = e + dy) >= 0) {
                                y1 = y1 + 1; // déplacement diagonal
                                e = e + dx;
                            }
                        }
                    }
                    else {
                        // vecteur oblique proche de la verticale, dans le 3e octant
                        int e;
                        dy = (e = dy) * 2;
                        dx = dx * 2; // e est positif
                        for (;;) { // déplacements verticaux
                            result ~= [x1, y1];
                            if ((y1 = y1 + 1) == y2)
                                break;
                            if ((e = e + dx) <= 0) {
                                x1 = x1 - 1; // déplacement diagonal
                                e = e + dy;
                            }
                        }
                    }

                }
                else { // dy < 0 (et dx < 0)
                    // vecteur oblique dans le 3e cadran

                    if (dx <= dy) {
                        // vecteur diagonal ou oblique proche de l’horizontale, dans le 5e octant
                        int e;
                        dx = (e = dx) * 2;
                        dy = dy * 2; // e est négatif
                        for (;;) { // déplacements horizontaux
                            result ~= [x1, y1];
                            if ((x1 = x1 - 1) == x2)
                                break;
                            if ((e = e - dy) >= 0) {
                                y1 = y1 - 1; // déplacement diagonal
                                e = e + dx;
                            }
                        }
                    }
                    else { // vecteur oblique proche de la verticale, dans le 6e octant
                        int e;
                        dy = (e = dy) * 2;
                        dx = dx * 2; // e est négatif
                        for (;;) { // déplacements verticaux
                            result ~= [x1, y1];
                            if ((y1 = y1 - 1) == y2)
                                break;
                            if ((e = e - dx) >= 0) {
                                x1 = x1 - 1; // déplacement diagonal
                                e = e + dy;
                            }
                        }
                    }

                }
            }
            else { // dy = 0 (et dx < 0)

                // vecteur horizontal vers la gauche
                do {
                    result ~= [x1, y1];
                }
                while ((x1 = x1 - 1) == x2);

            }
        }
    }
    else {
        if (dy != 0) {
            if (dy > 0) {
                // vecteur vertical croissant
                do {
                    result ~= [x1, y1];
                }
                while ((y1 = y1 + 1) == y2);

            }
            else {
                // vecteur vertical décroissant
                do {
                    result ~= [x1, y1];
                }
                while ((y1 = y1 - 1) == y2);

            }
        }
    }
    return result;
}

void drawGlyph(ulong glyph, int x, int y, int w, int h, int c) {
    ulong mask = 0x1L << (w * h + 7);
    for (int iy = y; iy < (y + h); ++iy) {
        for (int ix = x; ix < (x + w); ++ix) {
            if (glyph & mask) {
                _drawPixel(ix, iy, c);
            }
            mask >>= 1;
        }
    }
}

void printText(string text, int x, int y, int c) {
    import std.conv : to;

    if (c < 0 || c >= PALETTE_SIZE)
        return;

    const dstring dtext = to!dstring(text);
    foreach (ch; dtext) {
        if (ch == ' ') {
            x += FONT_ADVANCE;
            continue;
        }

        const ulong glyph = getGlyphData(ch);
        int widthOffset, heightOffset, descent;
        if (glyph) {
            descent = (glyph & 0xC0) >> 6;
            widthOffset = (glyph & 0x30) >> 4;
            heightOffset = glyph & 0xF;
            drawGlyph(glyph, x, y + descent + heightOffset,
                FONT_WIDTH - widthOffset, FONT_HEIGHT - heightOffset, c);
        }
        x += FONT_ADVANCE - widthOffset;
    }
}

void drawImage(Image image, int x, int y) {
    int i;
    for (int iy; iy < image._height; ++iy) {
        for (int ix; ix < image._width; ++ix) {
            if (image._texels[i] <= 15)
                _drawPixel(x + ix, y + iy, image._texels[i]);
            i++;
        }
    }
}
