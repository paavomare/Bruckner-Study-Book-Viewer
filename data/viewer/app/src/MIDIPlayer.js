import MidiPlayer from 'midi-player-js';
import Soundfont from 'soundfont-player';

class MIDIPlayer {
  constructor(callbacks) {
    this.audioContext = new AudioContext();
    this.isReady = false;
    this.midiPlayer = new MidiPlayer.Player();
    this.noteTracker = new Map();
    this.piano = null;
    this.callbacks = {
      end: () => {},
      pause: () => {},
      play: () => {},
      stop: () => {},
      ...callbacks,
    };

    this.onMidiEvent = this.onMidiEvent.bind(this);
  }

  init(callback = () => {}) {
    this.midiPlayer.setTempo(60);
    this.midiPlayer.on('midiEvent', this.onMidiEvent);
    this.midiPlayer.on('endOfFile', this.callbacks.end);
    Soundfont.instrument(this.audioContext, 'acoustic_grand_piano', {
      soundfont: 'FluidR3_GM',
    }).then(piano => {
      this.piano = piano;
      this.isReady = true;
      callback();
    });
  }

  loadMIDI(base64MIDI) {
    this.midiPlayer.loadDataUri(`data:audio/midi;base64,${base64MIDI}`);
  }

  noteOff(noteRef) {
    const audioNode = this.noteTracker.get(noteRef);
    if (audioNode !== undefined) {
      audioNode.stop(this.audioContext.currentTime);
    }
  }

  onMidiEvent({ name, noteName, track, velocity }) {
    if (name === 'Note on') {
      const noteRef = `${track}:${noteName}`;
      if (velocity > 0) {
        this.noteTracker.set(noteRef, this.piano.play(noteName));
      } else {
        this.noteOff(noteRef);
      }
    } else if (name === 'Note off') {
      const noteRef = `${track}:${noteName}`;
      this.noteOff(noteRef);
    }
  }

  getPlaybackStatus() {
    const songPercentRemaining = this.midiPlayer.getSongPercentRemaining();
    const tick = this.midiPlayer.getCurrentTick();
    const bpm = this.midiPlayer.tempo;
    const ppq = this.midiPlayer.getDivision().division;
    const currentMilliseconds = (60000 / (bpm * ppq)) * tick;
    return {
      currentMilliseconds,
      songPercentRemaining,
    };
  }

  setTempo(bpm) {
    this.midiPlayer.setTempo(bpm);
  }

  setPlaybackPosition(milliseconds) {
    // this.midiPlayer.skipToSeconds(milliseconds / 1000);
    const bpm = this.midiPlayer.tempo;
    const ppq = this.midiPlayer.getDivision().division;
    this.midiPlayer.skipToTick(milliseconds / (60000 / (bpm * ppq)));
  }

  pause() {
    this.midiPlayer.pause();
    this.piano.stop();
    this.noteTracker.clear();
    this.callbacks.pause();
  }

  play() {
    this.midiPlayer.play();
    this.callbacks.play();
  }

  stop() {
    this.midiPlayer.stop();
    this.piano.stop();
    this.noteTracker.clear();
    this.callbacks.stop();
  }
}

export default MIDIPlayer;
