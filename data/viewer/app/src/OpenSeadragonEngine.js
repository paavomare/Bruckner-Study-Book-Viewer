import OpenSeadragon from 'openseadragon';
import './vendor/openseadragon-svg-overlay';

const NO_OP = () => {};

const svg256 = () =>
  // eslint-disable-next-line max-len
  'data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22256px%22%20height%3D%22256px%22%2F%3E';

class OpenSeadragonEngine {
  constructor() {
    this.tileSources = [];
  }

  destroy() {
    this.overlay = null;
    this.viewer.destroy();
    this.viewer = null;
  }

  getViewerElement() {
    return this.viewerElement;
  }

  init(element, options = {}, pageCallback) {
    this.viewerElement = element;
    this.viewer = OpenSeadragon({
      element: this.viewerElement,
      tileSources: [],
      ...options,
    });

    // disable all built-in OpenSeadragon keys
    this.viewer.innerTracker.keyDownHandler = NO_OP;
    this.viewer.innerTracker.keyHandler = NO_OP;

    if (pageCallback !== undefined) {
      this.viewer.addHandler('page', event => {
        pageCallback(event.page);
      });
    }
  }

  open(page = 0) {
    this.viewer.open(this.tileSources, page);
  }

  setOverlaySVG(svg) {
    this.overlay.node().innerHTML = svg;
  }

  svgOverlay(scaleFactor = 1) {
    this.overlay = this.viewer.svgOverlay(scaleFactor);
  }

  setTileSources(tileSources) {
    this.tileSources = tileSources;
  }

  updateTileSource(tileSource, page) {
    const prevTileSource = this.tileSources[page];
    this.tileSources[page] = { ...prevTileSource, ...tileSource };
  }

  static defaultTileSource(tileSize, width, height, getTileUrl = svg256) {
    return {
      // also provide OSD defaults so we can compare tileSources
      ajaxWithCredentials: false,
      crossOriginPolicy: false,
      getTileUrl,
      height,
      tileSize,
      useCanvas: true,
      width,
    };
  }
}

export { OpenSeadragonEngine as OSD };
