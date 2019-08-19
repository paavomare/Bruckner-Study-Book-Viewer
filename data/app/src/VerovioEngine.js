/* global verovio */

const didKeysChange = (obj1, obj2, relevantKeys) =>
  relevantKeys.some(key => obj1[key] !== obj2[key]);

class VerovioEngine {
  constructor(options = {}) {
    this.isLoadRequired = true;
    this.loadedMei = '';
    this.loadedMeiPageCount = 0;
    this.calledRenderToMIDI = false;

    this.vrvToolkit = new verovio.toolkit();
    this.vrvToolkit.setOptions(options);

    this.loadedOptions = { ...options };
  }

  _loadIfNecessary(mei) {
    const meiHasChanged = mei !== this.loadedMei;
    const loadIsNecessary = meiHasChanged || this.isLoadRequired;
    if (loadIsNecessary) {
      this.vrvToolkit.loadData(mei, {});
      this.loadedMei = mei;
      this.loadedMeiPageCount = this.vrvToolkit.getPageCount();
      this.isLoadRequired = false;
      this.calledRenderToMIDI = false;
    }
  }

  destroy() {
    this.vrvToolkit.destroy();
    this.vrvToolkit = null;
  }

  getElementsAtTime(mei, milliseconds) {
    if (!this.calledRenderToMIDI) {
      this.getMIDI(mei);
    }
    return this.vrvToolkit.getElementsAtTime(milliseconds);
  }

  getMIDI(mei) {
    this._loadIfNecessary(mei);
    const base64MIDI = this.vrvToolkit.renderToMIDI({});
    this.calledRenderToMIDI = true;
    return base64MIDI;
  }

  getPageCount(mei) {
    this._loadIfNecessary(mei);
    return this.loadedMeiPageCount;
  }

  getPage(page) {
    return this.vrvToolkit.renderToSVG(page, {});
  }

  getSVG(mei, page, additionalOptions = {}) {
    this._loadIfNecessary(mei);
    return this.vrvToolkit.renderToSVG(page, additionalOptions);
  }

  getTimeForElement(mei, xmlId) {
    if (!this.calledRenderToMIDI) {
      this.getMIDI(mei);
    }
    return this.vrvToolkit.getTimeForElement(xmlId);
  }

  updateOptions(optionsToUpdate) {
    const updatedOptions = { ...this.loadedOptions, ...optionsToUpdate };
    this.isLoadRequired = didKeysChange(this.loadedOptions, updatedOptions, [
      'appXPathQuery',
      'choiceXPathQuery',
      'mdivXPathQuery',
      'substXPathQuery',
    ])
      ? true
      : this.isLoadRequired;

    this.vrvToolkit.setOptions(updatedOptions);
    this.loadedOptions = updatedOptions;
  }
}

export { VerovioEngine as Verovio };
