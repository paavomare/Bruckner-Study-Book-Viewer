import React from 'react';
import PropTypes from 'prop-types';

const Checkbox = ({ disabled, name, isChecked, onChange }) => (
  <input
    type="checkbox"
    name={name}
    disabled={disabled}
    checked={isChecked ? 'checked' : ''}
    onChange={onChange}
  />
);

Checkbox.propTypes = {
  disabled: PropTypes.bool,
  name: PropTypes.string.isRequired,
  isChecked: PropTypes.bool.isRequired,
  onChange: PropTypes.func.isRequired,
};

Checkbox.defaultProps = {
  disabled: false,
};

export default Checkbox;
