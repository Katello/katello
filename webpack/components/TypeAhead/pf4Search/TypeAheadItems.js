import React, { useEffect, useState } from 'react';
import {
  Dropdown,
  DropdownItem,
  DropdownSeparator,
} from '@patternfly/react-core';
import PropTypes from 'prop-types';

import { commonItemPropTypes } from '../helpers/commonPropTypes';

const TypeAheadItems = ({
  isOpen, items, activeItems, getItemProps, highlightedIndex,
}) => {
  const [dropdownItems, setDropdownItems] = useState([]);

  useEffect(() => {
    const newDropdownItems = items.map(({ text, type, disabled = false }, index) => {
      const key = `${text}${index}`;
      if (type === 'divider') return (<DropdownSeparator key={key} />);
      const isHovered = activeItems[highlightedIndex] === text;
      const itemProps = getItemProps({
        index: activeItems.indexOf(text),
        item: text,
        key,
        isHovered,
        disabled,
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
    setDropdownItems(newDropdownItems);
  }, [items, activeItems, highlightedIndex]);

  // toggle prop is required but since it is not manually toggled, React.Fragment is used to
  // satisfy the requirement
  return (
    <Dropdown
      toggle={<React.Fragment />}
      isOpen={isOpen}
      dropdownItems={dropdownItems}
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
