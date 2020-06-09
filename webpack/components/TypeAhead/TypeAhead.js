import React, { Component } from 'react';
import Downshift from 'downshift';
import PropTypes from 'prop-types';

import TypeAheadSearch from './pf3Search/TypeAheadSearch';
// eslint-disable-next-line import/no-named-default
import { default as TypeAheadSearchPf4 } from './pf4Search/TypeAheadSearch';
import { getActiveItems } from './helpers/helpers';

import './TypeAhead.scss';

class TypeAhead extends Component {
  constructor(props) {
    super(props);

    this.state = {
      inputValue: this.props.initialInputValue,
    };
  }

  handleStateChange = ({ inputValue }) => {
    if (typeof inputValue === 'string') {
      this.props.onInputUpdate(inputValue);
      this.setState({ inputValue });
    }
  };

  clearSearch = () => {
    this.setState({ inputValue: '' }, () => this.props.onSearch(this.state.inputValue));
  };

  render() {
    const {
      onSearch, onInputUpdate, items, actionText, patternfly4, autoSearchEnabled, ...rest
    } = this.props;

    const activeItems = getActiveItems(items);

    return (
      <Downshift
        onStateChange={this.handleStateChange}
        defaultHighlightedIndex={0}
        selectedItem={this.state.inputValue}
        {...rest}
      >
        {({
          getInputProps,
          getItemProps,
          isOpen,
          inputValue,
          highlightedIndex,
          selectedItem,
          selectItem,
          openMenu,
        }) => {
            const typeAheadProps = {
              userInputValue: this.state.inputValue,
              clearSearch: this.clearSearch,
              getInputProps,
              getItemProps,
              isOpen,
              inputValue,
              highlightedIndex,
              selectedItem,
              selectItem,
              openMenu,
              onSearch,
              items,
              activeItems,
              shouldShowItems: isOpen && items.length > 0,
           };

            return (
              <div>
                {patternfly4 ?
                  <TypeAheadSearchPf4 autoSearchEnabled={autoSearchEnabled} {...typeAheadProps} /> :
                  <TypeAheadSearch actionText={actionText} {...typeAheadProps} />}
              </div>
          );
}}
      </Downshift>
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
  initialInputValue: PropTypes.string,
  patternfly4: PropTypes.bool,
  autoSearchEnabled: PropTypes.bool.isRequired,
};

TypeAhead.defaultProps = {
  actionText: 'Search',
  initialInputValue: '',
  patternfly4: false,
};

export default TypeAhead;
