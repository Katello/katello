import React from 'react';
import { InputGroup, Button } from '@patternfly/react-core';
import { TimesIcon, SearchIcon } from '@patternfly/react-icons';

import keyPressHandler from '../helpers/helpers';
import TypeAheadInput from './TypeAheadInput';
import TypeAheadItems from './TypeAheadItems';
import commonSearchPropTypes from '../helpers/commonPropTypes';

const TypeAheadSearch = ({
  userInputValue, clearSearch, getInputProps, getItemProps, isOpen, inputValue, highlightedIndex,
  selectedItem, selectItem, openMenu, onSearch, items, activeItems, shouldShowItems,
}) => (
  <React.Fragment>
    <InputGroup>
      <TypeAheadInput
        onKeyPress={
          (e) => {
            keyPressHandler(
e, isOpen, activeItems, highlightedIndex,
                            selectItem, userInputValue, onSearch,
);
          }
        }
        onInputFocus={openMenu}
        passedProps={getInputProps()}
      />
      <React.Fragment>
        {userInputValue &&
          <Button variant="control" onClick={clearSearch}>
            <TimesIcon />
          </Button>}
      </React.Fragment>
      <Button aria-label="search button" variant="control" onClick={() => onSearch(inputValue)}>
        <SearchIcon />
      </Button>

    </InputGroup>
    <TypeAheadItems
      isOpen={shouldShowItems}
      {...{
      items, highlightedIndex, selectedItem, getItemProps, activeItems,
    }}
    />
  </React.Fragment>
);

TypeAheadSearch.propTypes = commonSearchPropTypes;

export default TypeAheadSearch;
