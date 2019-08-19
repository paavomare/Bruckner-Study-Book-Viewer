import PropTypes from 'prop-types';
import React from 'react';

import OpenSeadragon from 'openseadragon';

import { commonOpenSeadragonOptions } from '../osdOptions';

const facsimileOSDOptions = {
  defaultZoomLevel: 0,
  minZoomLevel: 0.67,
  sequenceMode: true,
};

class FacsimileViewer extends React.Component {
  constructor(props) {
    super(props);

    this.viewer = null;
    this.viewerDiv = React.createRef();

    this.initOpenSeadragon = this.initOpenSeadragon.bind(this);
  }

  initOpenSeadragon() {
    const { annotCreator, currentPage, onPage, tileSources } = this.props;
    this.viewer = OpenSeadragon({
      element: this.viewerDiv.current,
      tileSources,
      ...commonOpenSeadragonOptions,
      ...facsimileOSDOptions,
    });
    const annotFunc = annotCreator.bind(null, this.viewer);
    this.viewer.addHandler('open', annotFunc);
    this.viewer.addHandler('page', event => {
      onPage(event.page);
    });
    this.viewer.goToPage(currentPage);
    // disable all built-in OpenSeadragon keys
    this.viewer.innerTracker.keyDownHandler = () => {};
    this.viewer.innerTracker.keyHandler = () => {};
  }

  componentDidMount() {
    this.initOpenSeadragon();
  }

  componentDidUpdate(prevProps) {
    const { currentPage } = this.props;
    if (this.props.currentPage !== prevProps.currentPage) {
      this.viewer.goToPage(currentPage);
    }
  }

  componentWillUnmount() {
    this.viewer.destroy();
    this.viewer = null;
  }

  render() {
    return (
      <div
        id={this.props.viewerID}
        ref={this.viewerDiv}
        className="viewer facsimile-viewer"
      />
    );
  }
}

FacsimileViewer.propTypes = {
  annotCreator: PropTypes.func,
  currentPage: PropTypes.number,
  onPage: PropTypes.func,
  tileSources: PropTypes.array.isRequired,
  viewerID: PropTypes.string,
};

FacsimileViewer.defaultProps = {
  annotCreator: () => {},
  currentPage: 0,
  onPage: () => {},
  viewerID: 'facsimile-viewer',
};

export default FacsimileViewer;
