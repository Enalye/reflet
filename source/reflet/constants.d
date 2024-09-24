/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module reflet.constants;

enum WINDOW_WIDTH = 1920;
enum WINDOW_HEIGHT = 1080;
enum CANVAS_SCALE = 8;
enum CANVAS_WIDTH = WINDOW_WIDTH / CANVAS_SCALE;
enum CANVAS_HEIGHT = WINDOW_HEIGHT / CANVAS_SCALE;
enum FRAME_RATE = 60;
enum PALETTE_SIZE = 16;
enum TRANSPARENCY_VALUE = 0xFF;
enum CONTROLLER_DEAD_ZONE = 0.35;

enum FONT_WIDTH = 5;
enum FONT_HEIGHT = 11;
enum FONT_ADVANCE = 6;
enum FONT_LINE = 14;

enum Button {
    left = 0,
    right
}

enum Key {
    leftButton = 0x01,
    rightButton = 0x02,
    cancel = 0x03,
    middleButton = 0x04,
    xButton1 = 0x05,
    xButton2 = 0x06,
    back = 0x08,
    tab = 0x09,
    clear = 0x0C,
    return_ = 0x0D,
    shift = 0x10,
    control = 0x11,
    menu = 0x12,
    pause = 0x13,
    capital = 0x14,
    kana = 0x15,
    hangul = 0x15,
    junja = 0x17,
    final_ = 0x18,
    hanja = 0x19,
    kanji = 0x19,
    escape = 0x1B,
    convert = 0x1C,
    nonConvert = 0x1D,
    accept = 0x1E,
    modeChange = 0x1F,
    space = 0x20,
    prior = 0x21,
    next = 0x22,
    end = 0x23,
    home = 0x24,
    left = 0x25,
    up = 0x26,
    right = 0x27,
    down = 0x28,
    select = 0x29,
    print = 0x2A,
    execute = 0x2B,
    snapshot = 0x2C,
    insert = 0x2D,
    delete_ = 0x2E,
    help = 0x2F,
    alpha0 = 0x30,
    alpha1 = 0x31,
    alpha2 = 0x32,
    alpha3 = 0x33,
    alpha4 = 0x34,
    alpha5 = 0x35,
    alpha6 = 0x36,
    alpha7 = 0x37,
    alpha8 = 0x38,
    alpha9 = 0x39,
    a = 0x41,
    b = 0x42,
    c = 0x43,
    d = 0x44,
    e = 0x45,
    f = 0x46,
    g = 0x47,
    h = 0x48,
    i = 0x49,
    j = 0x4A,
    k = 0x4B,
    l = 0x4C,
    m = 0x4D,
    n = 0x4E,
    o = 0x4F,
    p = 0x50,
    q = 0x51,
    r = 0x52,
    s = 0x53,
    t = 0x54,
    u = 0x55,
    v = 0x56,
    w = 0x57,
    x = 0x58,
    y = 0x59,
    z = 0x5A,
    leftWindows = 0x5B,
    rightWindows = 0x5C,
    apps = 0x5D,
    sleep = 0x5F,
    num0 = 0x60,
    num1 = 0x61,
    num2 = 0x62,
    num3 = 0x63,
    num4 = 0x64,
    num5 = 0x65,
    num6 = 0x66,
    num7 = 0x67,
    num8 = 0x68,
    num9 = 0x69,
    multiply = 0x6A,
    add = 0x6B,
    separator = 0x6C,
    subtract = 0x6D,
    decimal = 0x6E,
    divide = 0x6F,
    f1 = 0x70,
    f2 = 0x71,
    f3 = 0x72,
    f4 = 0x73,
    f5 = 0x74,
    f6 = 0x75,
    f7 = 0x76,
    f8 = 0x77,
    f9 = 0x78,
    f10 = 0x79,
    f11 = 0x7A,
    f12 = 0x7B,
    f13 = 0x7C,
    f14 = 0x7D,
    f15 = 0x7E,
    f16 = 0x7F,
    f17 = 0x80,
    f18 = 0x81,
    f19 = 0x82,
    f20 = 0x83,
    f21 = 0x84,
    f22 = 0x85,
    f23 = 0x86,
    f24 = 0x87,
    numlock = 0x90,
    scroll = 0x91,
    leftShift = 0xA0,
    rightShift = 0xA1,
    leftControl = 0xA2,
    rightControl = 0xA3,
    leftMenu = 0xA4,
    rightMenu = 0xA5,
    browserBack = 0xA6,
    browserForward = 0xA7,
    browserRefresh = 0xA8,
    browserStop = 0xA9,
    browserSearch = 0xAA,
    browserFavorite = 0xAB,
    browserHome = 0xAC,
    volumeMute = 0xAD,
    volumeDown = 0xAE,
    volumeUp = 0xAF,
    mediaNextTrack = 0xB0,
    mediaPrevTrack = 0xB1,
    mediaStop = 0xB2,
    mediaPlayPause = 0xB3,
    launchMail = 0xB4,
    launchMediaSelect = 0xB5,
    launchApp1 = 0xB6,
    launchApp2 = 0xB7,
    oem1 = 0xBA,
    oemPlus = 0xBB,
    oemComma = 0xBC,
    oemMinus = 0xBD,
    oemPeriod = 0xBE,
    oem2 = 0xBF,
    oem3 = 0xC0,
    oem4 = 0xDB,
    oem5 = 0xDC,
    oem6 = 0xDD,
    oem7 = 0xDE,
    oem8 = 0xDF,
    oem102 = 0xE2,
    processKey = 0xE5,
    packet = 0xE7,
    attn = 0xF6,
    crSel = 0xF7,
    exSel = 0xF8,
    erEof = 0xF9,
    play = 0xFA,
    zoom = 0xFB,
    noName = 0xFC,
    pa1 = 0xFD,
    oemClear = 0xFE,
}