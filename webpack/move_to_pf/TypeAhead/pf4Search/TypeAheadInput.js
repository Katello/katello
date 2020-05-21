import React, { useRef } from 'react';
import { TextInput } from '@patternfly/react-core';

import useEventListener from '../../../utils/useEventListener';
import { commonInputPropTypes } from '../helpers/commonPropTypes';

const TypeAheadInput = ({ onKeyPress, onInputFocus, passedProps }) => {
  const inputRef = useRef(null);
  const { onChange, ...downshiftProps } = passedProps;

  // What patternfly4 expects for args and what downshift creates as a function is different,
  // downshift only expects the event handler
  const onChangeWrapper = (_userValue, event) => onChange(event);

  useEventListener('keydown', onKeyPress, inputRef.current);

  return (
    <TextInput
      {...downshiftProps}
      ref={inputRef}
      onFocus={onInputFocus}
      aria-label="text input for search"
      onChange={onChangeWrapper}
    />
  );
};

TypeAheadInput.propTypes = commonInputPropTypes;

export default TypeAheadInput;
