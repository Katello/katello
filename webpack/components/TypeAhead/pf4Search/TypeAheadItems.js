import React from 'react';
import {
  Dropdown,
  DropdownItem,
  DropdownSeparator,
  DropdownPosition,
} from '@patternfly/react-core';
import PropTypes from 'prop-types';

import { commonItemPropTypes } from '../helpers/commonPropTypes';

const TypeAheadItems = ({
  isOpen, items, activeItems, getItemProps, highlightedIndex,
}) => {
  const buildDropdownItems = () => items.map(({ text, type, disabled = false }, index) => {
    const key = `${text}${index}`;
    if (type === 'divider') return (<DropdownSeparator key={key} />);
    const isHighlighted = highlightedIndex === index;
    const itemProps = getItemProps({
      index: activeItems.indexOf(text),
      item: text,
      key,
      disabled,
      className: isHighlighted ? 'highlighted' : '',
    });
    const { onClick, ...dropdownProps } = itemProps;
    return (
      <DropdownItem
        {...dropdownProps}
        component={
          <button onClick={onClick}>{text}</button>
        }
      />
    );
  });

  // toggle prop is required but since it is not manually toggled, React.Fragment is used to
  // satisfy the requirement
  return (
    <Dropdown
      position={DropdownPosition.right}
      toggle={<React.Fragment />}
      isOpen={isOpen}
      dropdownItems={buildDropdownItems()}
      className="typeahead-dropdown"
    />
  );
};

TypeAheadItems.propTypes = {
  ...commonItemPropTypes,
  isOpen: PropTypes.bool,
};

TypeAheadItems.defaultProps = {
  isOpen: false,
};

export default TypeAheadItems;
