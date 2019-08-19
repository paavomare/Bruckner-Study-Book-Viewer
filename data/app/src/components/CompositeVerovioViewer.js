import React from 'react';
import PropTypes from 'prop-types';
import { zip } from 'lodash/array';

import { ZoomingVerovio } from '../ZoomingVerovio';
import { deepEquals } from '../util';

const buildSubstXPathQuery = substData =>
  Object.values(substData).map(value => `./*[@xml:id = '${value}']`);

class CompositeVerovioViewer extends React.Component {
  constructor(props) {
    super(props);

    this.viewerDiv = React.createRef();
    this.zv = new ZoomingVerovio(this.props.viewerID);

    this.showPage = this.showPage.bind(this);
  }

  componentDidMount() {
    this.zv.initOSD(this.props.viewerID, this.props.onPage);
    this.zv.setPageMapping(this.props.facsimileData);
    this.showPage();
  }

  componentDidUpdate(prevProps) {
    const { facsimileData, pageIndex, substData, substDefault } = this.props;
    if (!deepEquals(facsimileData, prevProps.facsimileData)) {
      this.zv.setPageMapping(facsimileData);
      this.showPage();
    }
    if (pageIndex !== prevProps.pageIndex) {
      this.showPage();
    }
    const substDefaultHasChanged = substDefault !== prevProps.substDefault;
    const substDataHasChanged = !deepEquals(substData, prevProps.substData);
    if (substDataHasChanged || substDefaultHasChanged) {
      this.showPage();
    }
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

  showPage() {
    const {
      facsimileData,
      getFile,
      onRender,
      pageIndex,
      substData,
      substDefault,
    } = this.props;
    const pageLabel = facsimileData.pages[pageIndex].label;
    const relevantData = facsimileData.locations[pageLabel];
    this.zv.updateVerovioOptions({
      substXPathQuery: [...buildSubstXPathQuery(substData), substDefault],
    });
    Promise.all(relevantData.map(l => l.filePath).map(getFile))
      .then(meiData => {
        this.zv.showComposite(
          pageIndex,
          zip(relevantData, meiData).map(([{ vrvPage }, mei]) => ({
            mei,
            vrvPage,
          })),
        );
        onRender({
          meiDocs: this.zv.docsUsed,
          viewerDiv: this.viewerDiv.current,
        });
      })
      .catch(error => console.log(error)); // eslint-disable-line no-console
  }
}

CompositeVerovioViewer.propTypes = {
  facsimileData: PropTypes.object,
  getFile: PropTypes.func.isRequired,
  onPage: PropTypes.func.isRequired,
  onRender: PropTypes.func.isRequired,
  substData: PropTypes.object,
  substDefault: PropTypes.string,
  pageIndex: PropTypes.number,
  viewerID: PropTypes.string.isRequired,
};

CompositeVerovioViewer.defaultProps = {
  facsimileData: {},
  pageIndex: 0,
  substData: {},
  substDefault: './add',
};

export default CompositeVerovioViewer;
