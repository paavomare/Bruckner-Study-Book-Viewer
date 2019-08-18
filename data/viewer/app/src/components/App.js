import axios from 'axios';
import React from 'react';
import OpenSeadragon from 'openseadragon';

import MIDIPlayer from '../MIDIPlayer';

import Controls from './Controls';
import ErrorBoundary from './ErrorBoundary';
import FacsimileViewer from './FacsimileViewer';
import VerovioViewer from './VerovioViewer';
import CompositeVerovioViewer from './CompositeVerovioViewer';

import { urls } from '../config';
import {
  MODE_FACS,
  MODE_RAW,
  MODE_WORK,
  ENDPOINT_FACS,
  ENDPOINT_FILE,
  ENDPOINT_LIST,
  ENDPOINT_XSLT,
  MIDI_PAUSE,
  MIDI_PLAY,
  MIDI_STOP,
} from '../constants';
import imageData from '../data/imagesIIIF';
import { annotData } from '../data/annotData';
import {
  addStyleToElements,
  getElementsBySelector,
  getElementsForXPath,
  getElementsWithIdsIfPresent,
} from '../interactDOM';
import { addTitlesToSpecialTones, drawBars, PROFILES } from '../analyse';

import { hot } from 'react-hot-loader/root';

import '../index.css';

const VEROVIO_ERROR_HELP = [
  'Looks like Verovio is unable to render the data.',
  'You can either try editing the data or select something else to render.',
  'As soon as you have done one of these things, click "Try to recover..."',
].join(' ');

const fetchFilesList = () =>
  axios
    .get(urls[ENDPOINT_LIST], { responseType: 'json' })
    .then(response => response.data.filenames)
    .catch(error => console.log(error)); // eslint-disable-line no-console

const fetchMEI = filePath =>
  axios
    .get(`${urls[ENDPOINT_FILE]}/${filePath}`, {
      responseType: 'text',
    })
    .then(response => response.data);

const XMLNSMAP = {
  mei: 'http://www.music-encoding.org/ns/mei',
};

const highlightSubstAddDel = (meiDoc, viewerDiv) => {
  const delElements = getElementsForXPath(
    meiDoc,
    '//*[ancestor::mei:del[not(parent::mei:subst)]]',
    XMLNSMAP,
  );
  const delIds = delElements.map(e => e.getAttribute('xml:id'));
  addStyleToElements(
    getElementsWithIdsIfPresent(viewerDiv, delIds),
    'del-only',
  );
  addStyleToElements(
    getElementsBySelector(viewerDiv, '.subst .del'),
    'subst-del',
  );
  addStyleToElements(
    getElementsBySelector(viewerDiv, '.subst .add'),
    'subst-add',
  );
};

const getSubstAlternatives = meiDoc => {
  const substElements = Array.from(meiDoc.getElementsByTagName('subst'));
  const substAlternatives = substElements.reduce((acc, substElement) => {
    const substId = substElement.getAttribute('xml:id');
    const alternatives = Array.from(substElement.children).filter(
      element => element.tagName === 'add' || element.tagName === 'del',
    );
    const alternativeIds = alternatives.map(e => e.getAttribute('xml:id'));
    return {
      ...acc,
      [substId]: alternativeIds,
    };
  }, {});
  return substAlternatives;
};

const getNextAlternativeId = (substElement, alternativeIds) => {
  const substChildren = getElementsBySelector(substElement, '.add, .del');
  const activeChild = substChildren.filter(e => e.hasChildNodes())[0];
  const currentId = activeChild.getAttribute('id');
  const index = alternativeIds.findIndex(
    alternativeId => alternativeId === currentId,
  );
  const newIndex = index < alternativeIds.length - 1 ? index + 1 : 0;
  return alternativeIds[newIndex];
};

const handleSubstClick = (substAlternatives, handlerFunc, event) => {
  const substElement = event.currentTarget;
  const substId = substElement.getAttribute('id');
  const alternativeId = getNextAlternativeId(
    substElement,
    substAlternatives[substId],
  );
  handlerFunc(substId, alternativeId);
};

const clearMidiActive = () => {
  const viewerDiv = document.getElementById('vViewer'); // not nice!
  const allNotes = viewerDiv.querySelectorAll('.note');
  allNotes.forEach(note => note.classList.remove('midi-active'));
};

const postXSLT = (url, postData) => {
  const formData = new FormData();
  Object.entries(postData).forEach(([key, value]) =>
    formData.append(key, value),
  );
  return axios.post(url, formData).then(response => response.data);
};

class App extends React.Component {
  constructor(props) {
    super(props);

    this.verovioViewer = React.createRef();

    this.state = {
      analyseWindowSize: 4,
      appMode: MODE_FACS,
      currentFileName: '',
      currentMeasureCount: 100,
      currentProfile: PROFILES[0],
      errorMsg: '',
      facsimileData: null,
      facsimilePage: 0,
      filesList: [],
      isAnnotStyleVisible: true,
      isDarkModeActivated: false,
      isEncodingVisible: true,
      isFacsViewerVisible: true,
      isLoading: false,
      mei: null,
      meiRendered: null,
      midiState: MIDI_STOP,
      midiTempo: 60,
      showKeys: false,
      substDefault: './add',
      substData: {},
      verovioPage: 1,
      verovioTotalPages: 1,
    };

    this.midiNeedsUpdate = true;
    this.midiPlayer = null;
    this.midiStatusInterval = null;

    this.fetchFacsData = this.fetchFacsData.bind(this);
    this.fetchFilesListShowFirst = this.fetchFilesListShowFirst.bind(this);
    this.getCurrentMIDI = this.getCurrentMIDI.bind(this);
    this.getTheMEI = this.getTheMEI.bind(this);
    this.handleAnalyse = this.handleAnalyse.bind(this);
    this.handleAnnot = this.handleAnnot.bind(this);
    this.handleCVerovioRender = this.handleCVerovioRender.bind(this);
    this.handleControlsChange = this.handleControlsChange.bind(this);
    this.handleDismissError = this.handleDismissError.bind(this);
    this.handleFacsimilePage = this.handleFacsimilePage.bind(this);
    this.handleMidi = this.handleMidi.bind(this);
    this.handleMidiStatus = this.handleMidiStatus.bind(this);
    this.handleReload = this.handleReload.bind(this);
    this.handleSubstBusiness = this.handleSubstBusiness.bind(this);
    this.handleVerovioLoad = this.handleVerovioLoad.bind(this);
    this.handleVerovioPage = this.handleVerovioPage.bind(this);
    this.handleVerovioRender = this.handleVerovioRender.bind(this);
    this.handleVerovioSubst = this.handleVerovioSubst.bind(this);
    this.initMIDI = this.initMIDI.bind(this);
    this.pauseMIDI = this.pauseMIDI.bind(this);
    this.playMIDI = this.playMIDI.bind(this);
    this.stopMIDI = this.stopMIDI.bind(this);
  }

  componentDidMount() {
    this.fetchFacsData();
    this.fetchFilesListShowFirst();

    // Shift+r reload mapping
    window.addEventListener('keyup', event => {
      if (event.shiftKey && event.keyCode === 82) {
        this.handleReload();
      }
    });
  }

  componentDidUpdate(_, prevState) {
    const {
      appMode,
      currentFileName,
      filesList,
      isDarkModeActivated,
      mei,
    } = this.state;
    // need to set this on body so it also works in OSD full screen mode
    if (isDarkModeActivated !== prevState.isDarkModeActivated) {
      document.body.classList.toggle('dark', isDarkModeActivated);
    }
    if (appMode !== prevState.appMode) {
      if (appMode === MODE_WORK || appMode === MODE_RAW) {
        this.setState({ mei: null, meiRendered: null }, () => {
          if (filesList.length === 0) {
            fetchFilesList().then(filesList =>
              this.setState({ filesList }, this.getTheMEI(filesList[0].name)),
            );
          } else {
            this.getTheMEI(currentFileName);
          }
        });
      } else if (appMode === MODE_FACS) {
        this.setState({ isFacsViewerVisible: true });
      }
    }
    if (mei !== prevState.mei) {
      this.midiNeedsUpdate = true;
    }
  }

  componentWillUnmount() {
    this.midiPlayer = null;
    clearInterval(this.midiStatusInterval);
  }

  fetchFacsData() {
    this.setState({ isLoading: true });
    axios
      .get(urls[ENDPOINT_FACS], { responseType: 'json' })
      .then(resp => resp.data.facsimileData)
      .then(facsimileData => {
        this.setState({ facsimileData, isLoading: false });
      })
      .catch(error => {
        console.log(error); // eslint-disable-line no-console
        this.setState({ errorMsg: error.message, isLoading: false });
      });
  }

  fetchFilesListShowFirst() {
    this.setState({ isLoading: true });
    fetchFilesList()
      .then(filesList => {
        const currentFileName = filesList[0].name;
        fetchMEI(currentFileName).then(mei =>
          this.setState({
            currentFileName,
            filesList,
            isLoading: false,
            mei,
            meiRendered: mei,
          }),
        );
      })
      .catch(error => {
        console.log(error); // eslint-disable-line no-console
        this.setState({ errorMsg: error.message, isLoading: false });
      });
  }

  getCurrentMIDI() {
    return this.verovioViewer.current.getMIDI();
  }

  getTheMEI(fileName) {
    const { appMode } = this.state;
    this.setState({ isLoading: true });
    fetchMEI(fileName)
      .then(
        appMode === MODE_WORK
          ? mei =>
              postXSLT(urls[ENDPOINT_XSLT], {
                __xslID: 'work',
                __xml: mei,
              })
          : mei => mei,
      )
      .then(mei =>
        this.setState({
          currentFileName: fileName,
          isLoading: false,
          mei,
          meiRendered: mei,
          showKeys: false,
        }),
      )
      .catch(error => {
        console.log(error); // eslint-disable-line no-console
        this.setState({ errorMsg: error.message, isLoading: false });
      });
  }

  handleAnalyse() {
    const { mei, analyseWindowSize, currentProfile } = this.state;
    this.setState({ isLoading: true });
    postXSLT(urls[ENDPOINT_XSLT], {
      __xslID: 'analyseByKey',
      __xml: mei,
      profile: currentProfile,
      windowSize: analyseWindowSize,
    })
      .then(meiAnalyse =>
        this.setState({
          isLoading: false,
          meiRendered: meiAnalyse,
          showKeys: true,
        }),
      )
      .catch(error => {
        console.log(error); // eslint-disable-line no-console
        this.setState({ errorMsg: error.message, isLoading: false });
      });
  }

  handleAnnot(viewerOSD) {
    const facsimileId = imageData[this.state.facsimilePage].url.split('/')[5];
    const zoneData = annotData[facsimileId];
    zoneData.forEach(zone => {
      const x = zone.ulx;
      const y = zone.uly;
      const width = zone.lrx - x;
      const height = zone.lry - y;
      const location = viewerOSD.viewport.imageToViewportRectangle(
        x,
        y,
        width,
        height,
      );
      const element = document.createElement('div');
      element.setAttribute('id', zone.id);
      element.classList.add('facs-overlay');
      element.classList.toggle('invisible', !this.state.isAnnotStyleVisible);
      const textEl = document.createElement('div');
      textEl.classList.add('facs-overlay-text');
      textEl.classList.add('invisible');
      textEl.innerHTML = zone.ann;
      textEl.addEventListener('click', () =>
        textEl.classList.toggle('invisible', true),
      );
      viewerOSD.addOverlay({
        element: textEl,
        location: new OpenSeadragon.Point(location.x, location.y),
      });
      textEl.querySelectorAll('.annot-abbr').forEach(span => {
        span.addEventListener('mouseenter', () => {
          span.innerHTML = span.getAttribute('data-expan');
        });
        span.addEventListener('mouseleave', () => {
          span.innerHTML = span.getAttribute('data-abbr');
        });
      });
      element.addEventListener('click', event => {
        // not sure where these offsets come from exactly
        const mouse = new OpenSeadragon.Point(
          event.pageX - 10,
          event.pageY - 40,
        );
        const mouseVP = viewerOSD.viewport.viewerElementToViewportCoordinates(
          mouse,
        );
        viewerOSD.updateOverlay(textEl, mouseVP);
        textEl.classList.toggle('invisible');
      });
      viewerOSD.addOverlay({
        element,
        location,
      });
    });
  }

  handleControlsChange(event) {
    const target = event.target;
    const value = target.type === 'checkbox' ? target.checked : target.value;
    const name = target.name;
    if (name === 'appMode') {
      this.setState({ appMode: value, showKeys: false });
    }
    if (name === 'substDefault') {
      this.setState({ substData: {} });
    }
    if (name === 'isAnnotStyleVisible') {
      document
        .querySelectorAll('.facs-overlay')
        .forEach(el => el.classList.toggle('invisible', !value));
      // also hide "open" annot texts
      if (!value) {
        document
          .querySelectorAll('.facs-overlay-text')
          .forEach(el => el.classList.toggle('invisible', true));
      }
    }
    if (name === 'currentFileName') {
      const { appMode, facsimileData } = this.state;
      let facsPage = -1;
      // open corresponding facsimile page
      const pageResult = Object.entries(facsimileData.locations).find(
        ([_, items]) => items.length > 0 && items[0].filePath === value,
      );
      if (pageResult !== undefined) {
        const label = pageResult[0];
        facsPage = facsimileData.pages.findIndex(p => p.label === label);
        if (appMode === MODE_WORK) {
          this.getTheMEI(value);
        }
      }
      if (appMode === MODE_FACS) {
        this.setState({ currentFileName: value });
      }
      if (facsPage >= 0) {
        this.handleFacsimilePage(facsPage);
      }
    } else if (name === 'facsimilePage') {
      const { facsimilePage } = this.state;
      const parseValue = parseInt(value, 10);
      const valueIsSensible =
        !isNaN(parseValue) && parseValue >= 0 && parseValue <= imageData.length;
      const newPage = valueIsSensible ? parseValue : facsimilePage;
      this.handleFacsimilePage(newPage);
    } else if (name === 'analyseWindowSize') {
      const { analyseWindowSize, currentMeasureCount } = this.state;
      const parseValue = parseInt(value, 10);
      const valueIsSensible =
        !isNaN(parseValue) &&
        parseValue > 0 &&
        parseValue <= currentMeasureCount;
      const newSize = valueIsSensible ? parseValue : analyseWindowSize;
      this.setState({ analyseWindowSize: newSize });
    } else if (name === 'midiTempo') {
      const { midiTempo } = this.state;
      const parseValue = parseInt(value, 10);
      const valueIsSensible =
        !isNaN(parseValue) && parseValue >= 1 && parseValue <= 240;
      const newTempo = valueIsSensible ? parseValue : midiTempo;
      this.setState({ midiTempo: newTempo });
    } else {
      this.setState({
        [name]: value,
      });
    }
  }

  handleCVerovioRender({ meiDocs, viewerDiv }) {
    meiDocs.forEach(meiDoc => {
      this.handleSubstBusiness(meiDoc, viewerDiv);
    });
  }

  handleDismissError() {
    this.setState({ errorMsg: '' });
  }

  handleFacsimilePage(facsimilePage) {
    if (facsimilePage === this.state.facsimilePage) {
      return;
    }
    // const imageId = imageData[facsimilePage].url.split('/')[5];
    // manageAnnotOverlays(viewer, annotData[imageId]);
    this.setState({ facsimilePage });
    const { appMode } = this.state;
    if (appMode === MODE_FACS) {
      const { facsimileData } = this.state;
      const pageLabel = facsimileData.pages[facsimilePage].label;
      const newFileName =
        facsimileData.locations[pageLabel].length > 0
          ? facsimileData.locations[pageLabel][0].filePath
          : undefined;
      if (newFileName !== undefined) {
        this.setState({ currentFileName: newFileName });
      }
    }
  }

  handleMidi(action) {
    if (action === MIDI_PAUSE) {
      this.pauseMIDI();
    } else if (action === MIDI_PLAY) {
      if (this.midiPlayer === null || !this.midiPlayer.isReady) {
        this.initMIDI(() => this.playMIDI());
      } else {
        this.playMIDI();
      }
    } else if (action === MIDI_STOP) {
      this.stopMIDI();
    }
  }

  handleMidiStatus() {
    const status = this.midiPlayer.getPlaybackStatus();
    const { currentMilliseconds } = status;
    // Verovio uses fixed tempo 120 for getElementsAtTime
    const vrvTime = (currentMilliseconds / 120) * this.state.midiTempo;
    const { notes, page } = this.verovioViewer.current.getElementsAtTime(
      Math.max(0, vrvTime - 100),
    );
    if (page !== this.state.verovioPage) {
      this.verovioViewer.current.setPage(page);
    }
    const viewerDiv = document.getElementById('vViewer'); // not nice!
    clearMidiActive();
    const activeNotes = getElementsWithIdsIfPresent(viewerDiv, notes);
    activeNotes.forEach(note => note.classList.add('midi-active'));
  }

  handleReload() {
    const { currentFileName } = this.state;
    this.getTheMEI(currentFileName);
  }

  handleSubstBusiness(meiDoc, viewerDiv) {
    highlightSubstAddDel(meiDoc, viewerDiv);
    const substAlternatives = getSubstAlternatives(meiDoc);
    const substIds = Object.keys(substAlternatives);
    const clickHandler = handleSubstClick.bind(
      null,
      substAlternatives,
      this.handleVerovioSubst,
    );
    getElementsWithIdsIfPresent(viewerDiv, substIds).forEach(element =>
      element.addEventListener('click', clickHandler),
    );
  }

  handleVerovioLoad(verovioTotalPages) {
    this.setState({ verovioTotalPages });
  }

  handleVerovioPage(verovioPage) {
    this.setState({ verovioPage });
  }

  handleVerovioRender({ meiDoc, viewerDiv }) {
    const { analyseWindowSize, appMode, showKeys } = this.state;
    const measures = Array.from(meiDoc.querySelectorAll('measure'));
    const measureCount = measures.length;
    this.setState({
      currentMeasureCount: measureCount,
      analyseWindowSize: Math.min(measureCount, analyseWindowSize),
    });
    if (appMode !== MODE_WORK) {
      this.handleSubstBusiness(meiDoc, viewerDiv);
    }
    if (showKeys) {
      drawBars(viewerDiv);
      addTitlesToSpecialTones(viewerDiv);
    }
    viewerDiv.querySelectorAll('.note').forEach(note =>
      note.addEventListener('click', event => {
        if (this.midiPlayer === null || !this.midiPlayer.isReady) {
          return;
        }
        const xmlId = event.target.parentElement.getAttribute('id');
        if (!xmlId) {
          return;
        }
        const time = this.verovioViewer.current.getTimeForElement(xmlId);
        const vrvTime = time * (120 / this.state.midiTempo);
        // const vrvTime = time;
        if (this.state.midiState === MIDI_PLAY) {
          this.pauseMIDI();
        }
        this.midiPlayer.setPlaybackPosition(vrvTime);
        if (this.state.midiState === MIDI_PAUSE) {
          this.playMIDI();
        }
      }),
    );
  }

  handleVerovioSubst(substId, alternativeId) {
    this.setState(prevState => ({
      substData: {
        ...prevState.substData,
        [substId]: alternativeId,
      },
    }));
  }

  initMIDI(callback) {
    this.midiPlayer = new MIDIPlayer({
      end: this.stopMIDI,
    });
    this.midiPlayer.init(callback);
  }

  pauseMIDI() {
    clearInterval(this.midiStatusInterval);
    this.midiPlayer.pause();
    this.setState({ midiState: MIDI_PAUSE });
  }

  playMIDI() {
    if (this.midiNeedsUpdate) {
      this.midiPlayer.loadMIDI(this.getCurrentMIDI());
      this.midiNeedsUpdate = false;
    }
    this.midiPlayer.setTempo(this.state.midiTempo);
    this.midiPlayer.play();
    this.midiStatusInterval = setInterval(this.handleMidiStatus, 100);
    this.setState({ midiState: MIDI_PLAY });
  }

  stopMIDI() {
    clearInterval(this.midiStatusInterval);
    clearMidiActive();
    this.midiPlayer.stop();
    this.setState({ midiState: MIDI_STOP });
  }

  render() {
    const {
      analyseWindowSize,
      appMode,
      currentFileName,
      currentProfile,
      errorMsg,
      isDarkModeActivated,
      facsimileData,
      facsimilePage,
      filesList,
      isAnnotStyleVisible,
      isEncodingVisible,
      isFacsViewerVisible,
      isLoading,
      mei,
      meiRendered,
      midiState,
      midiTempo,
      substData,
      substDefault,
      verovioPage,
      verovioTotalPages,
    } = this.state;
    return (
      <div id="app">
        <Controls
          analyseWindowSize={analyseWindowSize}
          appMode={appMode}
          currentFileName={currentFileName}
          currentProfile={currentProfile}
          errorMessage={errorMsg}
          facsimileData={facsimileData}
          facsimilePage={facsimilePage}
          filesList={filesList}
          isAnnotStyleVisible={isAnnotStyleVisible}
          isDarkModeActivated={isDarkModeActivated}
          isEncodingVisible={isEncodingVisible}
          isFacsViewerVisible={isFacsViewerVisible}
          midiState={midiState}
          midiTempo={midiTempo}
          onAnalyse={this.handleAnalyse}
          onChange={this.handleControlsChange}
          onDismissError={this.handleDismissError}
          onMidiControl={this.handleMidi}
          substDefault={substDefault}
          verovioPage={appMode === MODE_FACS ? facsimilePage + 1 : verovioPage}
          verovioTotalPages={
            appMode === MODE_FACS
              ? ((facsimileData && facsimileData.pages) || []).length
              : verovioTotalPages
          }
        />
        <div id="viewers">
          {isLoading && <div id="loading-indicator">Laden...</div>}
          <div
            id="actual-viewers"
            className={
              isFacsViewerVisible && isEncodingVisible
                ? 'viewersGrid'
                : 'viewersSolo'
            }
          >
            {isFacsViewerVisible && (
              <FacsimileViewer
                currentPage={facsimilePage}
                annotCreator={this.handleAnnot}
                onPage={this.handleFacsimilePage}
                tileSources={imageData.map(d => d.url)}
                viewerID="fViewer"
              />
            )}
            {isEncodingVisible && (
              <ErrorBoundary helpText={VEROVIO_ERROR_HELP}>
                {appMode === MODE_FACS
                  ? (facsimileData && (
                      <CompositeVerovioViewer
                        facsimileData={facsimileData}
                        getFile={fetchMEI}
                        onPage={this.handleFacsimilePage}
                        onRender={this.handleCVerovioRender}
                        pageIndex={facsimilePage}
                        substData={substData}
                        substDefault={substDefault}
                        viewerID="vViewer"
                      />
                    )) || <div>Laden...</div>
                  : (mei && (
                      <VerovioViewer
                        ref={this.verovioViewer}
                        onLoad={this.handleVerovioLoad}
                        onPage={this.handleVerovioPage}
                        onRender={this.handleVerovioRender}
                        mei={meiRendered}
                        substData={substData}
                        substDefault={substDefault}
                        viewerID="vViewer"
                      />
                    )) || <div>Laden...</div>}
              </ErrorBoundary>
            )}
          </div>
        </div>
      </div>
    );
  }
}

export default hot(App);
