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

    HHOOK _keyboardHook, _mouseHook;
}

import bindbc.sdl;
import grimoire;

import reflet.constants, reflet.script, reflet.font, reflet.image;

private {
    shared bool _isRunning = false;
    long _tickStartFrame;

    // Rendu
    SDL_Window* _window;
    SDL_Renderer* _renderer;
    SDL_Texture* _screenBuffer;
    SDL_Surface* _icon;
    ubyte[CANVAS_HEIGHT][CANVAS_WIDTH] _screen;
    bool _inputCapture = false;
    bool _isRendererDirty = false;

    /*
    Flag 0b1 -> Pressé ou non
    Flag 0b10 -> Changement lors de la frame ou non
    */
    ubyte[256] _keys;
    ubyte[2] _buttons;

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
    int _mouseX, _mouseY;

    // Programme
    GrEngine _engine;
}

/// Retourne la position de la souris.
int getMouseX() {
    return _mouseX;
}

///Ditto
int getMouseY() {
    return _mouseY;
}

void setInputCapture(bool inputCapture_) {
    _inputCapture = inputCapture_;
}

/// Capture les interruptions.
private extern (C) void _signalHandler(int sig) nothrow @nogc @system {
    cast(void) sig;
    _isRunning = false;
}

extern (Windows) LRESULT _keyboardHookCallback(int nCode, WPARAM wParam, LPARAM lParam) nothrow {
    KBDLLHOOKSTRUCT keyboardData;

    if (nCode >= 0) {
        if (wParam == WM_KEYDOWN) {
            keyboardData = *(cast(KBDLLHOOKSTRUCT*) lParam);
            if (keyboardData.vkCode < _keys.length) {
                _keys[keyboardData.vkCode] = 0b11;
            }
        }
        else if (wParam == WM_KEYUP) {
            keyboardData = *(cast(KBDLLHOOKSTRUCT*) lParam);
            if (keyboardData.vkCode < _keys.length) {
                _keys[keyboardData.vkCode] = 0b10;
            }
        }

        if (_inputCapture) {
            return 1;
        }
    }

    return CallNextHookEx(_keyboardHook, nCode, wParam, lParam);
}

extern (Windows) LRESULT _mouseHookCallback(int nCode, WPARAM wParam, LPARAM lParam) nothrow {
    if (nCode >= 0) {
        bool ignore;

        switch (wParam) {
        case WM_LBUTTONDOWN:
            _buttons[0] = 0b11;
            break;
        case WM_RBUTTONDOWN:
            _buttons[1] = 0b11;
            break;
        case WM_LBUTTONUP:
            _buttons[0] = 0b10;
            break;
        case WM_RBUTTONUP:
            _buttons[1] = 0b10;
            break;
        default:
            ignore = true;
            break;
        }

        if (_inputCapture && !ignore) {
            return 1;
        }
    }

    return CallNextHookEx(_keyboardHook, nCode, wParam, lParam);
}

private void _createHook() {
    //_keyboardHook = SetWindowsHookEx(WH_KEYBOARD_LL, &_keyboardHookCallback, null, 0);
    if (!_keyboardHook) {
        writeln("impossible de paramétrer le hook clavier");
    }

    //_mouseHook = SetWindowsHookEx(WH_MOUSE_LL, &_mouseHookCallback, null, 0);
    if (!_mouseHook) {
        writeln("impossible de paramétrer le hook souris");
    }
}

private void _releaseHook() {
    if (_keyboardHook) {
        UnhookWindowsHookEx(_keyboardHook);
    }
    if (_mouseHook) {
        UnhookWindowsHookEx(_mouseHook);
    }
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
    _createHook();

    _isRunning = true;

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

    _tickStartFrame = Clock.currStdTime();
    float accumulator = 0f;

    while (_isRunning) {
        long deltaTicks = Clock.currStdTime() - _tickStartFrame;
        double deltatime = (cast(float)(deltaTicks) / 10_000_000f) * FRAME_RATE;
        float currentFps = (deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
        _tickStartFrame = Clock.currStdTime();

        accumulator += deltatime;

        if (!_fetchEvents()) {
            break;
        }

        while (accumulator >= 1f) {
            /*if (bytecode && getButtonDown(KeyButton.f5)) {
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
        }*/

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

            for (int i; i < 0xff; ++i) {
                _keys[i] &= 0b01;
            }
            _buttons[0] &= 0b01;
            _buttons[1] &= 0b01;

            import std.conv : to;

            clearScreen(0);
            printText(to!string(currentFps), 0, 0, 5);

            _isRendererDirty = true;

            accumulator -= 1f;
        }

        _renderWindow();
        /*
        long deltaTicks = Clock.currStdTime() - _tickStartFrame;
        if (deltaTicks < (10_000_000 / FRAME_RATE))
            Thread.sleep(dur!("hnsecs")((10_000_000 / FRAME_RATE) - deltaTicks));

        deltaTicks = Clock.currStdTime() - _tickStartFrame;
        _tickStartFrame = Clock.currStdTime();*/
    }

    _destroyWindow();
}

ubyte getInputState(Key key) {
    return _keys[key];
}

ubyte getInputState(Button btn) {
    return _buttons[btn];
}

import core.sys.windows.windef;
import core.sys.windows.winuser;
import core.sys.windows.wingdi;

pragma(lib, "user32");

void _setWindowColorKey(SDL_Window* window) {
    SDL_SysWMinfo wmInfo;
    SDL_VERSION(&wmInfo.version_);
    SDL_GetWindowWMInfo(window, &wmInfo);
    HWND handle = wmInfo.info.win.window;
    SetWindowLong(handle, GWL_EXSTYLE, GetWindowLong(handle,
            GWL_EXSTYLE) | WS_EX_LAYERED | WS_EX_TOPMOST | WS_EX_TRANSPARENT);

    uint colorKey = _palette[0];
    COLORREF winColor = RGB((colorKey & 0xff0000) >> 16, (colorKey & 0xff00) >> 8, colorKey & 0xff);
    SetLayeredWindowAttributes(handle, winColor, 0, LWA_COLORKEY);

}

/// Create the application window.
private void _initWindow() {
    enforce(SDL_Init(0) == 0, "la sdl n'a pas pu s'initialiser: " ~ fromStringz(SDL_GetError()));
    /*
    enforce(SDL_CreateWindowAndRenderer(WINDOW_WIDTH, WINDOW_HEIGHT,
            SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC |
            SDL_WINDOW_ALWAYS_ON_TOP | SDL_WINDOW_BORDERLESS | SDL_WINDOW_SKIP_TASKBAR,
            &_window, &_renderer) != -1, "l'initialization de la fenêtre a échouée");*/

    _window = SDL_CreateWindow(toStringz("reflet"), 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT,
        SDL_WINDOW_ALWAYS_ON_TOP | SDL_WINDOW_BORDERLESS | SDL_WINDOW_SKIP_TASKBAR);
    enforce(_window, "l'initialization de la fenêtre a échouée");

    _renderer = SDL_CreateRenderer(_window, -1,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    enforce(_renderer, "l'initialization de la fenêtre a échouée");

    _screenBuffer = SDL_CreateTexture(_renderer, SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_STREAMING, CANVAS_WIDTH, CANVAS_HEIGHT);

    SDL_RenderSetLogicalSize(_renderer, CANVAS_WIDTH, CANVAS_HEIGHT);
    _setWindowColorKey(_window);

}

/// Cleanup the application window.
private void _destroyWindow() {
    _releaseHook();

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
    if (_isRendererDirty) {
        uint* pixels;
        int pitch;
        _isRendererDirty = false;
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
    }

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
