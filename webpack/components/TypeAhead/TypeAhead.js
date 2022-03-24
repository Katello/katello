import React, { useState, useEffect } from 'react';
import Downshift from 'downshift';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import TypeAheadSearch from './pf3Search/TypeAheadSearch';
// eslint-disable-next-line import/no-named-default
import { default as TypeAheadSearchPf4 } from './pf4Search/TypeAheadSearch';
import { getActiveItems } from './helpers/helpers';

import './TypeAhead.scss';
import useDebounce from '../../utils/useDebounce';

const TypeAhead = ({
  items,
  isDisabled,
  onInputUpdate,
  onSearch,
  actionText,
  initialInputValue,
  patternfly4,
  autoSearchEnabled,
  autoSearchDelay,
  bookmarkController,
  placeholder,
  isTextInput,
  setTextInputValue,
}) => {
  const [inputValue, setInputValue] = useState(initialInputValue);

  const debouncedValue = useDebounce(inputValue, autoSearchDelay);
  useEffect(
    () => {
      onInputUpdate(debouncedValue);
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [debouncedValue],
  );

  const handleStateChange = ({ inputValue: value }) => {
    if (typeof value === 'string') {
      setInputValue(value);
      if (setTextInputValue) setTextInputValue(value);
    }
  };

  const clearSearch = () => {
    setInputValue('');
    onSearch('');
  };

  const activeItems = getActiveItems(items);

  return (
    <Downshift
      onStateChange={handleStateChange}
      defaultHighlightedIndex={0}
      selectedItem={inputValue}
    >
      {({
        getInputProps,
        getItemProps,
        isOpen,
        inputValue: internalInputValue,
        highlightedIndex,
        selectedItem,
        selectItem,
        openMenu,
      }) => {
        const typeAheadProps = {
          bookmarkController,
          isDisabled,
          userInputValue: inputValue,
          clearSearch,
          getInputProps,
          getItemProps,
          isOpen,
          inputValue: internalInputValue,
          highlightedIndex,
          selectedItem,
          selectItem,
          openMenu,
          onSearch,
          items,
          activeItems,
          placeholder,
          shouldShowItems: isOpen && items.length > 0,
          isTextInput,
        };

        return (
          <div>
            {patternfly4 ?
              <TypeAheadSearchPf4 autoSearchEnabled={autoSearchEnabled} {...typeAheadProps} /> :
              <TypeAheadSearch actionText={actionText} {...typeAheadProps} placeholder={null} />}
          </div>
        );
      }}
    </Downshift>
  );
};

TypeAhead.propTypes = {
  items: PropTypes.arrayOf(PropTypes.shape({
    /* text to display in MenuItem  */
    text: PropTypes.string,
    /* item can be a header or divider or undefined for regular item */
    type: PropTypes.oneOf(['header', 'divider']),
    /* optionally disable a regular item */
    disabled: PropTypes.bool,
  })).isRequired,
  isDisabled: PropTypes.bool,
  onInputUpdate: PropTypes.func.isRequired,
  onSearch: PropTypes.func.isRequired,
  actionText: PropTypes.string,
  initialInputValue: PropTypes.string,
  patternfly4: PropTypes.bool,
  autoSearchEnabled: PropTypes.bool.isRequired,
  autoSearchDelay: PropTypes.number,
  bookmarkController: PropTypes.string,
  placeholder: PropTypes.string,
  isTextInput: PropTypes.bool,
  setTextInputValue: PropTypes.func,
};

TypeAhead.defaultProps = {
  actionText: __('Search'),
  initialInputValue: '',
  patternfly4: false,
  isDisabled: undefined,
  autoSearchDelay: 500,
  bookmarkController: undefined,
  placeholder: undefined,
  isTextInput: false,
  setTextInputValue: undefined,
};

export default TypeAhead;
