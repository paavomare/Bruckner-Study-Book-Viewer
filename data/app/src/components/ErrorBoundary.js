import PropTypes from 'prop-types';
import React from 'react';

import Button from './Button';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      error: null,
      hasError: false,
    };

    this.attemptRecovery = this.attemptRecovery.bind(this);
  }

  attemptRecovery() {
    this.setState({
      error: null,
      hasError: false,
    });
  }

  componentDidCatch(error) {
    // componentDidCatch(error, info) {
    // Display fallback UI
    this.setState({
      error: error,
      hasError: true,
    });
    // You can also log the error to an error reporting service
    // logErrorToMyService(error, info.componentStack);
  }

  render() {
    const { error, hasError } = this.state;
    if (hasError) {
      const { helpText } = this.props;
      return (
        <div className="errorboundary">
          <h1>Something went wrong.</h1>
          <h3>Error:</h3>
          <div className="code-error">
            <code>{error}</code>
          </div>
          {helpText && <p>{helpText}</p>}
          <Button className="button-inline" onClick={this.attemptRecovery}>
            Try to recover...
          </Button>
        </div>
      );
    }
    return this.props.children;
  }
}

ErrorBoundary.propTypes = {
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]).isRequired,
  helpText: PropTypes.string,
};

ErrorBoundary.defaultProps = {
  helpText: '',
};

export default ErrorBoundary;
