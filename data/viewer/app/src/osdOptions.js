export const commonOpenSeadragonOptions = {
  constrainDuringPan: true,
  gestureSettingsMouse: {
    clickToZoom: false,
    dblClickToZoom: true,
  },
  maxZoomLevel: 10,
  prefixUrl: 'openseadragon/images/',
  showHomeControl: true,
  showZoomControl: false,
  visibilityRatio: 1,
};

export const commonVerovioOpenSeadragonOptions = {
  defaultZoomLevel: 0, // automatically fit viewport
  minZoomLevel: 0.67, // allow for fitting whole page
  sequenceMode: true,
};
