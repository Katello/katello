import React, { Component } from 'react';
import Downshift from 'downshift';
import PropTypes from 'prop-types';

import { InputGroup, Button } from 'patternfly-react';
import TypeAheadInput from './TypeAheadInput';
import TypeAheadItems from './TypeAheadItems';
import { getActiveItems } from './helpers';

import './TypeAhead.scss';

const KEY_CODES = { TAB_KEY: 9, ENTER_KEY: 13 };

class TypeAhead extends Component {
  constructor(props) {
    super(props);

    this.state = {
      inputValue: '',
    };

    this.handleStateChange = this.handleStateChange.bind(this);
  }

  handleStateChange({ inputValue }) {
    if (typeof inputValue === 'string') {
      this.props.onInputUpdate(inputValue);
      this.setState({ inputValue });
    }
  }

  render() {
    const {
      onSearch, onInputUpdate, items, actionText, ...rest
    } = this.props;

    const activeItems = getActiveItems(items);

    return (
      <Downshift
        onStateChange={this.handleStateChange}
        defaultHighlightedIndex={0}
        selectedItem={this.state.inputValue}
        {...rest}
        render={({
          getInputProps,
          getItemProps,
          isOpen,
          inputValue,
          highlightedIndex,
          selectedItem,
          selectItem,
          openMenu,
        }) => {
          const shouldShowItems = isOpen && items.length > 0;
          const autoCompleteItemsProps = {
            items,
            highlightedIndex,
            selectedItem,
            getItemProps,
            activeItems,
          };

          return (
            <div>
              <InputGroup>
                <TypeAheadInput
                  onKeyPress={(e) => {
                    switch (e.keyCode) {
                      case KEY_CODES.TAB_KEY:
                        if (isOpen && activeItems[highlightedIndex]) {
                          selectItem(activeItems[highlightedIndex]);
                          e.preventDefault();
                        }

                        break;

                      case KEY_CODES.ENTER_KEY:
                        if (!isOpen || !activeItems[highlightedIndex]) {
                          onSearch(this.state.inputValue);
                          e.preventDefault();
                        }

                        break;

                      default:
                        break;
                    }
                  }}
                  onInputFocus={openMenu}
                  passedProps={getInputProps()}
                />
                <InputGroup.Button>
                  <Button onClick={() => onSearch(inputValue)}>{actionText}</Button>
                </InputGroup.Button>
              </InputGroup>

              {shouldShowItems && <TypeAheadItems {...autoCompleteItemsProps} />}
            </div>
          );
        }}
      />
    );
  }
}

TypeAhead.propTypes = {
  items: PropTypes.arrayOf(PropTypes.shape({
    /* text to display in MenuItem  */
    text: PropTypes.string,
    /* item can be a header or divider or undefined for regular item */
    type: PropTypes.oneOf(['header', 'divider']),
    /* optionally disable a regular item */
    disabled: PropTypes.bool,
  })).isRequired,
  onInputUpdate: PropTypes.func.isRequired,
  onSearch: PropTypes.func.isRequired,
  actionText: PropTypes.string,
};

TypeAhead.defaultProps = {
  actionText: 'Search',
};

export default TypeAhead;
