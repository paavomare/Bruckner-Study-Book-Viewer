const commonOptions = {
  adjustPageHeight: true,
  bottomMarginHarm: 3.0,
  breaks: 'encoded',
  evenNoteSpacing: true,
  font: 'Bravura',
  minMeasureWidth: 30,
  noFooter: true,
  noHeader: true,
  pageMarginBottom: 100,
  pageMarginLeft: 100,
  pageMarginRight: 100,
  pageMarginTop: 40,
  pageWidth: 8192,
  scale: 220,
  substXPathQuery: './add',
  topMarginHarm: 3.0,
};

export const getVerovioOptions = options => ({
  ...commonOptions,
  ...options,
});
