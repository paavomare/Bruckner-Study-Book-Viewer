import PropTypes from 'prop-types';
import React from 'react';

const TextInput = ({
  classNames,
  disabled,
  numbersOnly,
  name,
  onChange,
  onClick,
  onFocus,
  value,
}) => (
  <input
    type={numbersOnly ? 'number' : 'text'}
    className={classNames}
    disabled={disabled}
    name={name}
    onChange={onChange}
    onClick={onClick}
    onFocus={onFocus}
    value={value}
  />
);

TextInput.propTypes = {
  classNames: PropTypes.string,
  disabled: PropTypes.bool,
  name: PropTypes.string.isRequired,
  numbersOnly: PropTypes.bool,
  onChange: PropTypes.func.isRequired,
  onClick: PropTypes.func,
  onFocus: PropTypes.func,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
};

TextInput.defaultProps = {
  classNames: '',
  disabled: false,
  numbersOnly: false,
  onClick: () => {},
  onFocus: () => {},
};

export default TextInput;
