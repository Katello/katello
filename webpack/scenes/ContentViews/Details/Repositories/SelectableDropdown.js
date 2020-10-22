import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Select, SelectOption, SelectVariant, Level, LevelItem } from '@patternfly/react-core';

const SelectableDropdown = ({
  items, title, selected, setSelected,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const onSelect = (event, selection) => {
    setSelected(selection);
    setIsOpen(false);
  };
  const onToggle = open => setIsOpen(open);

  const selectItems = items.map(item => <SelectOption key={item} value={item} aria-label={`select ${item}`} />);

  return (
    <Level>
      <LevelItem>
        <label htmlFor={`select ${title}`} style={{ margin: '0px 5px' }}>
          {`${title}:`}
        </label>
      </LevelItem>
      <LevelItem aria-label={`select ${title} container`}>
        <Select
          id={`select ${title}`}
          key="type-dropdown"
          variant={SelectVariant.single}
          onToggle={onToggle}
          onSelect={onSelect}
          selections={selected}
          isOpen={isOpen}
        >
          {selectItems}
        </Select>
      </LevelItem>
    </Level>
  );
};

SelectableDropdown.propTypes = {
  items: PropTypes.arrayOf(PropTypes.string).isRequired,
  title: PropTypes.string.isRequired,
  selected: PropTypes.string.isRequired,
  setSelected: PropTypes.func.isRequired,
};


export default SelectableDropdown;
