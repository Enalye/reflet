/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module reflet.audio.input;

import core.thread;
import std.exception : enforce;
import std.string;
import bindbc.sdl;

import std.numeric;

import reflet.constants;

/// Représente un périphérique audio
final class AudioInput {
    private {
        /// Représente le périphérique audio
        SDL_AudioDeviceID _deviceId;
    }

    @property {
    }

    /// Init
    this(string deviceName = "") {
        _openAudio(deviceName);
    }

    /// Déinit
    ~this() {
        _closeAudio();
    }

    /// Initialise le module audio
    private void _openAudio(string deviceName) {
        SDL_AudioSpec desired, obtained;

        desired.freq = Audio_SampleRate;
        desired.channels = 1;
        desired.samples = Audio_FrameSize;
        desired.format = AUDIO_F32;
        desired.callback = &_callback;

        if (deviceName.length) {
            const(char)* deviceCStr = toStringz(deviceName);
            _deviceId = SDL_OpenAudioDevice(deviceCStr, 1, &desired, &obtained, 0);
        }
        else {
            _deviceId = SDL_OpenAudioDevice(null, 1, &desired, &obtained, 0);
        }
        play();
    }

    /// Ferme le module audio
    private void _closeAudio() {
        SDL_CloseAudioDevice(_deviceId);
        _deviceId = 0;
    }

    void play() {
        SDL_PauseAudioDevice(_deviceId, 0);
    }

    void stop() {
        SDL_PauseAudioDevice(_deviceId, 1);
    }

    static private extern (C) void _callback(void* userData, ubyte* stream, int len) nothrow {
        len >>= 2; // 8 bit -> 32 bit

        float* buffer = cast(float*) stream;
        for (int i; i < len; i++) {
            //buffer[i] = masterBuffer[i];
        }
    }
}
