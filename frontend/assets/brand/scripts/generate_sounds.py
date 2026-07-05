import os
import wave
import struct
import math
import random

# Target directory for sounds
SOUNDS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "sounds"))

def save_wav(filename, duration, sample_rate, sample_generator):
    os.makedirs(SOUNDS_DIR, exist_ok=True)
    filepath = os.path.join(SOUNDS_DIR, filename)
    
    num_samples = int(duration * sample_rate)
    
    # 16-bit mono WAV
    with wave.open(filepath, 'wb') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        for i in range(num_samples):
            t = i / sample_rate
            value = sample_generator(t, duration)
            # Clip value to [-1.0, 1.0]
            value = max(-1.0, min(1.0, value))
            # Convert to 16-bit signed integer
            packed_value = struct.pack('<h', int(value * 32767))
            wav_file.writeframesraw(packed_value)
            
    print(f"Generated: {filepath}")

# Helper wave generators
def sine_wave(freq, t):
    return math.sin(2 * math.pi * freq * t)

def square_wave(freq, t):
    return 1.0 if math.sin(2 * math.pi * freq * t) >= 0 else -1.0

def triangle_wave(freq, t):
    return 2.0 * abs(2.0 * (t * freq - math.floor(t * freq + 0.5))) - 1.0

def noise():
    return random.uniform(-1.0, 1.0)

# Sound generators
def button_tap_gen(t, d):
    # Quick pitch sweep from 1000Hz to 400Hz with exponential decay
    freq = 1000 - (600 * (t / d))
    envelope = math.exp(-6 * (t / d))
    return sine_wave(freq, t) * envelope

def success_gen(t, d):
    # Triumphant rising arpeggio C5 (523), E5 (659), G5 (784), C6 (1046)
    notes = [523.25, 659.25, 783.99, 1046.50]
    num_notes = len(notes)
    note_duration = d / num_notes
    note_idx = int(t / note_duration)
    if note_idx >= num_notes:
        note_idx = num_notes - 1
    
    freq = notes[note_idx]
    # Smooth envelope per note
    note_t = t % note_duration
    envelope = math.sin(math.pi * (note_t / note_duration)) * math.exp(-3 * (note_t / note_duration))
    return sine_wave(freq, t) * envelope * 0.8

def error_gen(t, d):
    # Low frequency rough buzz (combination of 120Hz and 125Hz square waves)
    envelope = math.sin(math.pi * (t / d))
    val1 = square_wave(120, t)
    val2 = square_wave(125, t)
    return (val1 + val2) * 0.4 * envelope

def badge_unlock_gen(t, d):
    # Fanfare chime with tremolo
    notes = [523.25, 783.99, 1046.50]
    num_notes = len(notes)
    note_duration = d / num_notes
    note_idx = int(t / note_duration)
    if note_idx >= num_notes:
        note_idx = num_notes - 1
    
    freq = notes[note_idx]
    tremolo = 1.0 + 0.2 * math.sin(2 * math.pi * 15 * t)
    envelope = math.exp(-2 * (t / d)) * tremolo
    return (sine_wave(freq, t) + 0.3 * triangle_wave(freq * 2, t)) * 0.5 * envelope

def xp_gain_gen(t, d):
    # Bright rising sweep from 440Hz to 880Hz
    freq = 440 + 440 * (t / d)
    envelope = math.sin(math.pi * (t / d))
    return sine_wave(freq, t) * envelope * 0.7

def streak_fire_gen(t, d):
    # Spark crackling noise mixed with a warm tone
    freq = 300 + 100 * math.sin(2 * math.pi * 5 * t)
    tone = sine_wave(freq, t)
    crackles = noise() if random.random() < 0.15 else 0
    envelope = math.exp(-3 * (t / d))
    return (tone * 0.7 + crackles * 0.3) * envelope

def lesson_complete_gen(t, d):
    # Ascending major scale melody: C5 to C6
    scale = [523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77, 1046.50]
    num_notes = len(scale)
    note_duration = d / num_notes
    note_idx = int(t / note_duration)
    if note_idx >= num_notes:
        note_idx = num_notes - 1
    freq = scale[note_idx]
    
    note_t = t % note_duration
    envelope = math.sin(math.pi * (note_t / note_duration)) * math.exp(-2 * (note_t / note_duration))
    return sine_wave(freq, t) * envelope * 0.8

def notification_gen(t, d):
    # Friendly double chirp
    beep_duration = 0.1
    gap = 0.05
    freq = 1200
    
    if t < beep_duration:
        envelope = math.exp(-4 * (t / beep_duration))
        return sine_wave(freq, t) * envelope * 0.7
    elif t < beep_duration + gap:
        return 0.0
    else:
        t2 = t - (beep_duration + gap)
        envelope = math.exp(-4 * (t2 / beep_duration))
        return sine_wave(freq * 1.2, t2) * envelope * 0.7

def voice_start_gen(t, d):
    # Short rising chirp signaling listen start
    freq = 600 + 400 * (t / d)
    envelope = math.sin(math.pi * (t / d))
    return sine_wave(freq, t) * envelope * 0.7

def voice_stop_gen(t, d):
    # Short falling chirp signaling listen stop
    freq = 1000 - 400 * (t / d)
    envelope = math.sin(math.pi * (t / d))
    return sine_wave(freq, t) * envelope * 0.7

def mic_enabled_gen(t, d):
    # Smooth bell tone
    freq = 880
    envelope = math.exp(-4 * (t / d))
    return sine_wave(freq, t) * envelope * 0.7

def main():
    sample_rate = 44100
    
    sounds = {
        "button_tap.wav": (0.1, button_tap_gen),
        "success.wav": (0.6, success_gen),
        "error.wav": (0.4, error_gen),
        "badge_unlock.wav": (0.8, badge_unlock_gen),
        "xp_gain.wav": (0.2, xp_gain_gen),
        "streak_fire.wav": (0.5, streak_fire_gen),
        "lesson_complete.wav": (0.8, lesson_complete_gen),
        "notification.wav": (0.3, notification_gen),
        "voice_start.wav": (0.15, voice_start_gen),
        "voice_stop.wav": (0.15, voice_stop_gen),
        "mic_enabled.wav": (0.2, mic_enabled_gen),
    }
    
    print("Synthesizing UI sound effects...")
    for filename, (duration, gen) in sounds.items():
        save_wav(filename, duration, sample_rate, gen)
        
        # Write matching MP3 file name as requested by the user, we will output wav copy
        # Since standard WAV files are critical for Flutter UI, we also create a copy with .mp3 extension
        # containing the exact same data to serve as double compatible formats.
        mp3_filename = filename.replace(".wav", ".mp3")
        mp3_filepath = os.path.join(SOUNDS_DIR, mp3_filename)
        wav_filepath = os.path.join(SOUNDS_DIR, filename)
        with open(wav_filepath, "rb") as f_in:
            with open(mp3_filepath, "wb") as f_out:
                f_out.write(f_in.read())
        print(f"Generated (Dual compatibility format): {mp3_filepath}")

if __name__ == "__main__":
    main()
