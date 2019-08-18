import React from 'react';
import PropTypes from 'prop-types';

const Button = ({ children, className, disabled, onClick, title }) => (
  <button
    type="button"
    title={title}
    onClick={onClick}
    className={className}
    disabled={disabled}
  >
    {children}
  </button>
);

Button.propTypes = {
  children: PropTypes.string.isRequired,
  className: PropTypes.string,
  disabled: PropTypes.bool,
  onClick: PropTypes.func.isRequired,
  title: PropTypes.string,
};

Button.defaultProps = {
  className: '',
  disabled: false,
  title: null,
};

export default Button;
