import React from 'react';
import { InputGroup, Button, Icon } from 'patternfly-react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import TypeAheadInput from './TypeAheadInput';
import TypeAheadItems from './TypeAheadItems';
import keyPressHandler from '../helpers/helpers';
import commonSearchPropTypes from '../helpers/commonPropTypes';

const TypeAheadSearch = ({
  userInputValue, clearSearch, getInputProps, getItemProps, isOpen, inputValue, highlightedIndex,
  selectedItem, selectItem, openMenu, onSearch, items, activeItems, actionText, shouldShowItems,
}) => (
  <div>
    <InputGroup>
      <TypeAheadInput
        onKeyPress={e => keyPressHandler(
          e, isOpen, activeItems, highlightedIndex,
          selectItem, userInputValue, onSearch,
        )}
        onInputFocus={openMenu}
        passedProps={getInputProps()}
      />
      {userInputValue &&
        <InputGroup.Button>
          <Button onClick={clearSearch}>
            <Icon name="times" />
          </Button>
        </InputGroup.Button>
      }
      <InputGroup.Button>
        <Button aria-label="patternfly 3 search button" onClick={() => onSearch(inputValue)}>{actionText}</Button>
      </InputGroup.Button>
    </InputGroup>

    {shouldShowItems && <TypeAheadItems {...{
      items, highlightedIndex, selectedItem, getItemProps, activeItems,
    }}
    />}
  </div>
);

TypeAheadSearch.propTypes = {
  ...commonSearchPropTypes,
  actionText: PropTypes.string,
};

TypeAheadSearch.defaultProps = {
  actionText: __('Search'),
};

export default TypeAheadSearch;
