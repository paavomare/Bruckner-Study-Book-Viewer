import React from 'react';
import PropTypes from 'prop-types';

import Button from './Button';
import Checkbox from './Checkbox';
import TextInput from './TextInput';

import {
  MODE_FACS,
  MODE_RAW,
  MODE_WORK,
  MIDI_PAUSE,
  MIDI_PLAY,
  MIDI_STOP,
} from '../constants';

import { PROFILES } from '../analyse';

const selectOnClick = event => {
  event.target.select();
};

const substDefaultToggled = {
  './add': './del',
  './del': './add',
};

const getSubstDefaultButton = (substXPath, handleChange) => {
  const label = substXPath.slice(2, 5);
  const value = substDefaultToggled[substXPath];
  const event = { target: { name: 'substDefault', value } };
  return (
    <Button
      className={`button-inline button-toggle subst-${label}`}
      title="Varianten"
      onClick={() => handleChange(event)}
    >
      {label}
    </Button>
  );
};

const getColorModeButton = (isDarkModeActivated, handleChange) => {
  const label = isDarkModeActivated ? 'dark' : 'light';
  const value = !isDarkModeActivated;
  const event = { target: { name: 'isDarkModeActivated', value } };
  return (
    <Button
      className={`button-inline button-toggle colors-${label}`}
      title="Farbschema"
      onClick={() => handleChange(event)}
    >
      &nbsp;
    </Button>
  );
};

const Separator = () => <span>&nbsp;&nbsp;|&nbsp;&nbsp;</span>;

const Controls = ({
  analyseWindowSize,
  appMode,
  currentFileName,
  currentProfile,
  errorMessage,
  onAnalyse,
  onChange,
  onDismissError,
  facsimileData,
  facsimilePage,
  filesList,
  isAnnotStyleVisible,
  isDarkModeActivated,
  isFacsViewerVisible,
  isEncodingVisible,
  onMidiControl,
  midiState,
  midiTempo,
  substDefault,
  verovioPage,
  verovioTotalPages,
}) => (
  <div id="controls">
    <span id="controls-left">
      <span id="control-appmode">
        <select
          id="select-appmode"
          title="Modus"
          name="appMode"
          onChange={onChange}
          value={appMode}
        >
          <option value={MODE_FACS}>Edition</option>
          <option value={MODE_WORK}>Analyse</option>
        </select>
      </span>
      <span>
        <Separator />
        <span id="control-facvisible">
          <Checkbox
            disabled={
              !(isEncodingVisible && isFacsViewerVisible) && isFacsViewerVisible
            }
            name="isFacsViewerVisible"
            isChecked={isFacsViewerVisible}
            onChange={onChange}
          />
          Faksimile
        </span>
        &nbsp;
        {isFacsViewerVisible && (
          <span id="controls-facs">
            <span id="control-facspage">
              <select
                id="select-facspage"
                title="Seite"
                name="facsimilePage"
                onChange={onChange}
                value={facsimilePage}
              >
                {facsimileData ? (
                  facsimileData.pages.map((page, i) => (
                    <option key={i} value={i}>
                      {page.label}
                    </option>
                  ))
                ) : (
                  <option>Laden...</option>
                )}
              </select>
            </span>
            <Separator />
            <span id="control-annotvisible">
              <Checkbox
                name="isAnnotStyleVisible"
                isChecked={isAnnotStyleVisible}
                onChange={onChange}
              />
              Annotationen
            </span>
          </span>
        )}
      </span>
      {errorMessage && (
        <span>
          <Separator />
          <Button
            className="button-inline error-indicator"
            onClick={onDismissError}
            title="Schließen"
          >
            ERROR: {errorMessage}
          </Button>
        </span>
      )}
    </span>
    <span id="controls-right">
      {isEncodingVisible && (
        <span>
          <span id="control-filenames">
            <select
              id="select-filenames"
              title={currentFileName}
              name="currentFileName"
              onChange={onChange}
              value={currentFileName}
              style={{ minWidth: '18em' }}
            >
              {filesList.length > 0 ? (
                filesList.map(fileName => (
                  <option key={fileName.name} value={fileName.name}>
                    {fileName.label || fileName.name}
                  </option>
                ))
              ) : (
                <option>Laden...</option>
              )}
            </select>
            &nbsp;
          </span>
          <span id="control-veroviopage">
            {verovioPage} / {verovioTotalPages}
          </span>
          <Separator />
          {(appMode === MODE_FACS || appMode === MODE_RAW) && (
            <span>
              <span id="control-substdefault">
                {getSubstDefaultButton(substDefault, onChange)}
              </span>
              <Separator />
            </span>
          )}
          {appMode === MODE_WORK && (
            <span id="control-analyse">
              <Button
                className="button-inline button-analyse"
                onClick={onAnalyse}
              >
                Analyse
              </Button>
              <span>&nbsp;</span>
              <select
                id="select-profile"
                title="Tonarten-Profil"
                name="currentProfile"
                onChange={onChange}
                value={currentProfile}
              >
                {PROFILES.map(profile => (
                  <option key={profile} value={profile}>
                    {profile}
                  </option>
                ))}
              </select>
              <TextInput
                classNames="input-facspage"
                name="analyseWindowSize"
                numbersOnly
                onChange={onChange}
                onClick={selectOnClick}
                value={analyseWindowSize}
              />
              <Separator />
            </span>
          )}
          {(appMode === MODE_WORK || appMode === MODE_RAW) && (
            <span id="controls-midi">
              <span>&#9834;</span>
              <span>&nbsp;</span>
              {midiState === MIDI_PAUSE || midiState === MIDI_STOP ? (
                <Button
                  className="button-inline"
                  onClick={() => onMidiControl(MIDI_PLAY)}
                >
                  &#9654;
                </Button>
              ) : (
                <Button
                  className="button-inline"
                  onClick={() => onMidiControl(MIDI_PAUSE)}
                >
                  &#9646;&#9646;
                </Button>
              )}
              {(midiState === MIDI_PAUSE || midiState === MIDI_PLAY) && (
                <span>
                  <span>&nbsp;</span>
                  <Button
                    className="button-inline"
                    onClick={() => onMidiControl(MIDI_STOP)}
                  >
                    &#9724;
                  </Button>
                </span>
              )}
              <span>&nbsp;</span>
              <TextInput
                classNames="input-facspage"
                disabled={midiState === MIDI_PLAY}
                name="midiTempo"
                numbersOnly
                onChange={onChange}
                onClick={selectOnClick}
                value={midiTempo}
              />
              <Separator />
            </span>
          )}
          <span id="control-colors">
            {getColorModeButton(isDarkModeActivated, onChange)}
          </span>
        </span>
      )}
    </span>
  </div>
);

Controls.propTypes = {
  analyseWindowSize: PropTypes.number.isRequired,
  appMode: PropTypes.string.isRequired,
  currentFileName: PropTypes.string.isRequired,
  currentProfile: PropTypes.string.isRequired,
  errorMessage: PropTypes.string,
  facsimileData: PropTypes.object,
  facsimilePage: PropTypes.number.isRequired,
  filesList: PropTypes.arrayOf(PropTypes.object).isRequired,
  isAnnotStyleVisible: PropTypes.bool.isRequired,
  isDarkModeActivated: PropTypes.bool.isRequired,
  isEncodingVisible: PropTypes.bool.isRequired,
  isFacsViewerVisible: PropTypes.bool.isRequired,
  midiState: PropTypes.string.isRequired,
  midiTempo: PropTypes.number.isRequired,
  onAnalyse: PropTypes.func.isRequired,
  onChange: PropTypes.func.isRequired,
  onDismissError: PropTypes.func.isRequired,
  onMidiControl: PropTypes.func.isRequired,
  substDefault: PropTypes.string.isRequired,
  verovioPage: PropTypes.number.isRequired,
  verovioTotalPages: PropTypes.number.isRequired,
};

Controls.defaultProps = {
  errorMessage: '',
};

export default Controls;
