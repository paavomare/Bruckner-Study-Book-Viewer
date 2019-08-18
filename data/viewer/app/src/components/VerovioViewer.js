/* global verovio */
import PropTypes from 'prop-types';
import React from 'react';

import OpenSeadragon from 'openseadragon';
import '../vendor/openseadragon-svg-overlay';

import {
  commonOpenSeadragonOptions,
  commonVerovioOpenSeadragonOptions,
} from '../osdOptions';
import { deepEquals, rangeArray } from '../util';
import { getVerovioOptions } from '../verovioOptions';

const PAGEWIDTH = 8192;
const TILESIZE = 256;
const NUMHORIZTILES = Math.ceil(PAGEWIDTH / TILESIZE);
const OVERLAYFACTOR = (1 / PAGEWIDTH) * 0.99; // scale down overlay
const ZOOM = 220;

const verovioOptions = getVerovioOptions({
  breaks: 'auto', // assuming this will used for works only
  pageWidth: (TILESIZE * NUMHORIZTILES * 100) / ZOOM,
  scale: ZOOM,
  leftMarginNote: 1.25,
  leftMarginRest: 1.25,
  rightMarginNote: 1.25,
  rightMarginRest: 1.25,
});

// extract effective page height from svg string
const getPageHeight = svg => {
  const firstLine = svg.split('\n', 1)[0];
  const height = /height="(\d+)/.exec(firstLine)[1];
  return parseInt(height, 10);
};

const svg256 = () =>
  // eslint-disable-next-line max-len
  'data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22256px%22%20height%3D%22256px%22%2F%3E';

const emptyTileSource = {
  // also provide OSD defaults so we can compare tileSources
  ajaxWithCredentials: false,
  crossOriginPolicy: false,
  getTileUrl: svg256,
  tileSize: TILESIZE,
  height: Math.floor(TILESIZE * NUMHORIZTILES * 0.75),
  useCanvas: true,
  width: TILESIZE * NUMHORIZTILES,
};

const getTileSource = height => ({
  ...emptyTileSource,
  height,
});

const buildSubstXPathQuery = substData =>
  Object.keys(substData).map(key => `./*[@xml:id = '${substData[key]}']`);

const domParser = new DOMParser();

class VerovioViewer extends React.Component {
  constructor(props) {
    super(props);

    this.viewerDiv = React.createRef();
    this.viewer = null;
    this.tileSources = [];
    this.overlay = null;
    this.vrvToolkit = new verovio.toolkit();

    this.dataId = null;
    this.prevDataId = null;
    this.numPages = 0;
    this.currentPage = 1;
    this.prevPage = 0;

    this.getMIDI = this.getMIDI.bind(this);
    this.initOpenSeadragon = this.initOpenSeadragon.bind(this);
    this.loadMEI = this.loadMEI.bind(this);
    this.renderSVG = this.renderSVG.bind(this);
  }

  getMIDI() {
    return this.vrvToolkit.renderToMIDI({});
  }

  getElementsAtTime(milliseconds) {
    return this.vrvToolkit.getElementsAtTime(milliseconds);
  }

  getTimeForElement(xmlId) {
    return this.vrvToolkit.getTimeForElement(xmlId);
  }

  setPage(page) {
    this.currentPage = page;
    this.renderSVG();
  }

  initOpenSeadragon() {
    this.viewer = OpenSeadragon({
      element: this.viewerDiv.current,
      tileSources: [],
      ...commonOpenSeadragonOptions,
      ...commonVerovioOpenSeadragonOptions,
    });
    this.overlay = this.viewer.svgOverlay(OVERLAYFACTOR);
    this.viewer.addHandler('page', event => {
      this.prevPage = this.currentPage;
      this.currentPage = event.page + 1;
      this.renderSVG();
    });
    // disable all built-in OpenSeadragon keys
    this.viewer.innerTracker.keyDownHandler = () => {};
    this.viewer.innerTracker.keyHandler = () => {};
  }

  loadMEI(mei) {
    // determine xml:id of root mei element
    this.meiDoc = domParser.parseFromString(mei, 'text/xml');
    this.prevDataId = this.dataId;
    this.dataId = this.meiDoc.documentElement.getAttribute('xml:id');
    const meiIdHasChanged = this.dataId !== this.prevDataId;
    // reset current and previous page if data id has changed
    this.prevPage = meiIdHasChanged ? 0 : this.currentPage;
    this.currentPage = meiIdHasChanged ? 1 : this.currentPage;
    // apply subst data
    const { substData, substDefault } = this.props;
    const substXPathQuery = [...buildSubstXPathQuery(substData), substDefault];
    this.vrvToolkit.setOptions({
      ...verovioOptions,
      substXPathQuery,
    });
    // verovio-load mei
    try {
      this.vrvToolkit.loadData(mei, {});
    } catch (err) {
      const log = this.vrvToolkit.getLog();
      console.log(log); // eslint-disable-line no-console
      throw new Error(err + '\n' + log);
    }
    // get page count
    const numPages = this.vrvToolkit.getPageCount();
    if (numPages !== this.numPages) {
      // re-create tile sources if page count has changed
      this.tileSources = rangeArray(numPages).map(() => emptyTileSource);
      this.numPages = numPages;
    }
    // pass back page count
    this.props.onLoad(numPages);
  }

  renderSVG() {
    // determine page
    const page = this.currentPage;
    // verovio-render SVG
    const svg = this.vrvToolkit.renderToSVG(page, {});
    // set overlay contents
    this.overlay.node().innerHTML = svg;
    // determine OSD page index
    const osdPage = page - 1;
    // determine if viewport should be preserved:
    // check if data id has changed
    const meiIdHasChanged = this.dataId !== this.prevDataId;
    // check if page has changed
    const pageHasChanged = this.currentPage !== this.prevPage;
    // determine height change
    const prevHeight = this.tileSources[osdPage].height;
    const newHeight = getPageHeight(svg);
    const heightDiff = newHeight - prevHeight;
    const heightDiffIsTooGreat = Math.abs(heightDiff) > prevHeight * 0.05;
    if (meiIdHasChanged || pageHasChanged || heightDiffIsTooGreat) {
      // create "new" tile source
      const newTileSource = getTileSource(newHeight);
      // replace relevant tile source
      this.tileSources[osdPage] = newTileSource;
      // open "new" tile sources eith relevant page
      this.viewer.open(this.tileSources, osdPage);
    }
    const { onPage, onRender } = this.props;
    // pass back page
    onPage(page);
    // pass back meiDoc, viewerDiv
    onRender({ meiDoc: this.meiDoc, viewerDiv: this.viewerDiv.current });
  }

  componentDidMount() {
    this.initOpenSeadragon();
    const { mei } = this.props;
    this.loadMEI(mei);
    this.renderSVG();
  }

  componentDidUpdate(prevProps) {
    const { mei, substData, substDefault } = this.props;
    const meiHasChanged = mei != prevProps.mei;
    const substDefaultHasChanged = substDefault !== prevProps.substDefault;
    const substDataHasChanged = !deepEquals(substData, prevProps.substData);
    if (meiHasChanged || substDefaultHasChanged || substDataHasChanged) {
      this.loadMEI(mei);
      this.renderSVG();
    }
  }

  componentWillUnmount() {
    this.overlay = null;
    this.viewer.destroy();
    this.viewer = null;
    this.vrvToolkit.destroy();
    this.vrvToolkit = null;
  }

  render() {
    return (
      <div
        id={this.props.viewerID}
        ref={this.viewerDiv}
        className="viewer verovio-viewer"
      />
    );
  }
}

VerovioViewer.propTypes = {
  mei: PropTypes.string.isRequired,
  onLoad: PropTypes.func,
  onPage: PropTypes.func,
  onRender: PropTypes.func,
  substData: PropTypes.objectOf(PropTypes.string),
  substDefault: PropTypes.string,
  viewerID: PropTypes.string,
};

VerovioViewer.defaultProps = {
  onLoad: () => {},
  onPage: () => {},
  onRender: () => {},
  substData: {},
  substDefault: './add',
  viewerID: 'verovio-viewer',
};

export default VerovioViewer;
