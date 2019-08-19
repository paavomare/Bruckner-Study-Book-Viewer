import { OSD } from './OpenSeadragonEngine';
import { Verovio } from './VerovioEngine';
import { getVerovioOptions } from './verovioOptions';
import {
  commonOpenSeadragonOptions,
  commonVerovioOpenSeadragonOptions,
} from './osdOptions';

const PAGEWIDTH = 8192;
const TILESIZE = 256;
const ZOOM = 220;
const NUMHORIZTILES = Math.ceil(PAGEWIDTH / TILESIZE);
const OVERLAYFACTOR = (1 / PAGEWIDTH) * 0.99; // scale down overlay

const osdOptions = {
  ...commonOpenSeadragonOptions,
  ...commonVerovioOpenSeadragonOptions,
};

const V_MARGIN_TOP = 40;
const V_MARGIN_LEFT = 100;

const verovioOptions = getVerovioOptions({
  breaks: 'encoded',
  pageMarginTop: V_MARGIN_TOP,
  pageWidth: (TILESIZE * NUMHORIZTILES * 100) / ZOOM,
  scale: ZOOM,
});

const emptyTileSource = () =>
  OSD.defaultTileSource(
    TILESIZE,
    TILESIZE * NUMHORIZTILES,
    Math.floor(TILESIZE * NUMHORIZTILES * 0.75),
  );

const parser = new DOMParser();
const parseXML = xml => parser.parseFromString(xml, 'text/xml');

const serializer = new XMLSerializer();
const serializeXML = doc => serializer.serializeToString(doc);

const getHeight = svgDoc => {
  const heightAttr = svgDoc.documentElement.getAttribute('height');
  return parseInt(heightAttr.replace('px', ''), 10);
};

const sum = xs => xs.reduce((x, y) => x + y, 0);

const mergeSVG = (svg1, svg2) => {
  const svgDocs = [parseXML(svg1), parseXML(svg2)];
  const newDoc = svgDocs[0];
  // merge defs
  const [defs1, defs2] = Array.from(
    svgDocs.map(pn => pn.querySelector('defs')),
  );
  defs2.querySelectorAll('symbol').forEach(symbol => {
    const symbolId = symbol.getAttribute('id');
    if (!defs1.querySelector(`#${symbolId}`)) {
      defs1.append(newDoc.importNode(symbol, true));
    }
  });
  // add root element height attributes
  const totalHeight = sum(svgDocs.map(getHeight));
  newDoc.documentElement.setAttribute('height', `${totalHeight}px`);
  // add viewBox height
  const payloads = svgDocs.map(pn => pn.querySelector('svg.definition-scale'));
  const vbAttrs = payloads.map(e => e.getAttribute('viewBox'));
  const [[minX1, minY1, width1, height1], [_x, _y, _w, height2]] = vbAttrs.map(
    s => s.split(' ').map(n => parseInt(n, 10)),
  );
  const vbValsSum = [minX1, minY1, width1, height1 + height2];
  const newViewBox = vbValsSum.join(' ');
  const [payload1, payload2] = payloads;
  payload1.setAttribute('viewBox', newViewBox);
  // move second content down by first content's height
  const pageMarginG2 = payload2.querySelector('g.page-margin');
  pageMarginG2.setAttribute(
    'transform',
    `translate(${10 * V_MARGIN_LEFT}, ${height1 - 3 * 10 * V_MARGIN_TOP})`,
    // the 3 is "magical"
  );
  // append contents of second svg to first
  payload1.append(pageMarginG2);
  return serializeXML(newDoc);
};

const MEI_NS = 'http://www.music-encoding.org/ns/mei';

const ensurePageBreak = mei => {
  const meiDoc = parseXML(mei);
  const section1 = meiDoc.querySelector('section');
  const firstChild = section1.firstElementChild;
  let pageBreakInserted = false;
  if (firstChild.localName !== 'pb') {
    section1.insertBefore(meiDoc.createElementNS(MEI_NS, 'pb'), firstChild);
    pageBreakInserted = true;
  }
  return {
    xml: serializeXML(meiDoc),
    pageBreakInserted,
  };
};

function removeGeneratedMeasures(mei) {
  const meiDoc = parseXML(mei);
  meiDoc
    .querySelectorAll('measure[type="generated"]')
    .forEach(measure => measure.remove());
  return serializeXML(meiDoc);
}

export class ZoomingVerovio {
  constructor() {
    this.osd = new OSD();
    this.vrv = new Verovio(verovioOptions);
    this.pageData = null;
    this.pageCallback = null;
    this.lastPageShown = -1;
    this.docsUsed = [];
  }

  initOSD(element, pageCallback) {
    this.pageCallback = pageCallback;
    this.osd.init(element, osdOptions, this.pageCallback);
    this.osd.svgOverlay(OVERLAYFACTOR);
  }

  setPageMapping(pageData) {
    this.pageData = pageData;
    this.osd.setTileSources(this.pageData.pages.map(emptyTileSource));
  }

  showComposite(osdPage, pageInfo) {
    this.docsUsed = [];
    const svg =
      pageInfo.length > 0
        ? pageInfo
            .map(({ mei, vrvPage }) => {
              const { xml, pageBreakInserted } = ensurePageBreak(mei);
              const xml2 = removeGeneratedMeasures(xml);
              this.docsUsed.push(parseXML(xml2));
              return this.vrv.getSVG(xml2, vrvPage + +pageBreakInserted);
            })
            .reduce(mergeSVG)
        : '';
    const rawHeight = svg ? getHeight(parseXML(svg)) : 1;
    const height = Math.ceil(rawHeight / TILESIZE) * TILESIZE;
    this.osd.updateTileSource({ height }, osdPage);
    this.osd.setOverlaySVG(svg);
    // preserve viewport if page hasn't changed
    if (this.lastPageShown !== osdPage) {
      this.osd.open(osdPage);
      this.lastPageShown = osdPage;
    }
  }

  updateVerovioOptions(options) {
    this.vrv.updateOptions(options);
  }
}
