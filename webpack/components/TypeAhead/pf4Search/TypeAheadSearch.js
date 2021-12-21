import React from 'react';
import { InputGroup, Button } from '@patternfly/react-core';
import { SearchIcon } from '@patternfly/react-icons';

import PropTypes from 'prop-types';
import keyPressHandler from '../helpers/helpers';
import TypeAheadInput from './TypeAheadInput';
import TypeAheadItems from './TypeAheadItems';
import commonSearchPropTypes from '../helpers/commonPropTypes';
import Bookmark from './../../../components/Bookmark';

const TypeAheadSearch = ({
  userInputValue, clearSearch, getInputProps, getItemProps, isOpen, highlightedIndex,
  selectedItem, selectItem, openMenu, onSearch, items, activeItems, shouldShowItems,
  autoSearchEnabled, isDisabled, bookmarkController, inputValue, placeholder,
}) => (
  <>
    <InputGroup>
      <TypeAheadInput
        isDisabled={isDisabled}
        onKeyPress={
          (e) => {
            keyPressHandler(
              e,
              isOpen,
              activeItems,
              highlightedIndex,
              selectItem,
              userInputValue,
              onSearch,
            );
          }
        }
        onInputFocus={openMenu}
        passedProps={{ ...getInputProps(), clearSearch }}
        autoSearchEnabled={autoSearchEnabled}
        placeholder={placeholder}
      />
      <>
        {bookmarkController &&
          <Bookmark
            {...{
              isDisabled,
              selectedItem,
              selectItem,
            }}
            controller={bookmarkController}
          />}
        {!autoSearchEnabled &&
          <Button aria-label="search button" variant="control" onClick={() => onSearch(inputValue)}>
            <SearchIcon />
          </Button>}
      </>
    </InputGroup>
    <TypeAheadItems
      isOpen={shouldShowItems}
      {...{
        items, highlightedIndex, selectedItem, getItemProps, activeItems,
      }}
    />
  </>
);

TypeAheadSearch.propTypes = {
  isDisabled: PropTypes.bool,
  autoSearchEnabled: PropTypes.bool.isRequired,
  bookmarkController: PropTypes.string,
  ...commonSearchPropTypes,
};

TypeAheadSearch.defaultProps = {
  bookmarkController: undefined,
  isDisabled: undefined,
};

export default TypeAheadSearch;
