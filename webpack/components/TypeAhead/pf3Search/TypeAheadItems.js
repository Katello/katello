import React from 'react';
import { Dropdown, MenuItem } from 'patternfly-react';

import { commonItemPropTypes } from '../helpers/commonPropTypes';

const TypeAheadItems = ({
  items, activeItems, getItemProps, highlightedIndex,
}) => (
  <Dropdown.Menu className="typeahead-dropdown" ouiaId="typeahead-dropdown">
    {items.map(({ text, type, disabled = false }, index) => {
      if (type === 'header') {
        return (
          <MenuItem key={text} header>
            {text}
          </MenuItem>
        );
      }

      if (type === 'divider') {
        // eslint-disable-next-line react/no-array-index-key
        return <MenuItem key={`divider-${index}`} divider />;
      }

      if (disabled) {
        return (
          <MenuItem key={text} disabled>
            {text}
          </MenuItem>
        );
      }

      const itemProps = getItemProps({
        index: activeItems.indexOf(text),
        item: text,
        active: activeItems[highlightedIndex] === text,
        onClick: (e) => {
          // At this point the event.defaultPrevented
          // is already set to true by react-bootstrap
          // MenuItem. We need to set it back to false
          // So downshift will execute it's own handler
          e.defaultPrevented = false;
        },
      });

      return (
        <MenuItem {...itemProps} key={text}>
          {text}
        </MenuItem>
      );
    })}
  </Dropdown.Menu>
);

TypeAheadItems.propTypes = commonItemPropTypes;

export default TypeAheadItems;
