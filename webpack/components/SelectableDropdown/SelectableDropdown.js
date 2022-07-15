import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Spinner, Select, SelectOption, SelectVariant, Level, LevelItem } from '@patternfly/react-core';
import { ErrorCircleOIcon } from '@patternfly/react-icons';


const SelectableDropdown = ({
  items, title, showTitle, selected, setSelected, loading, error, isDisabled,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const icon = () => {
    if (error) return <span aria-label={`${title} error`}><ErrorCircleOIcon color="red" /></span>;
    if (loading) return <span aria-label={`${title} spinner`}><Spinner size="sm" /></span>;
    return null;
  };
  const onSelect = (_event, selection) => {
    setSelected(selection);
    setIsOpen(false);
  };
  const onToggle = open => setIsOpen(open);

  const selectItems = items.map(item => <SelectOption key={item} value={item} aria-label={`select ${item}`} />);

  return (
    <Level>
      {showTitle &&
      <LevelItem>
        <label htmlFor={`select ${title}`} style={{ margin: '0px 5px' }}>
          {title}
        </label>
      </LevelItem>
      }
      <LevelItem aria-label={`select ${title} container`}>
        <Select
          id={`select ${title}`}
          ouiaId={`select ${title}`}
          aria-label={`select ${title}`}
          key="type-dropdown"
          variant={SelectVariant.single}
          onToggle={onToggle}
          onSelect={onSelect}
          selections={selected}
          isOpen={isOpen}
          isDisabled={loading || error || isDisabled}
          toggleIcon={icon()}
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
  showTitle: PropTypes.bool,
  selected: PropTypes.string.isRequired,
  setSelected: PropTypes.func.isRequired,
  // If the items are loaded dynamically, you can pass in loading or error states
  loading: PropTypes.bool,
  error: PropTypes.bool,
  isDisabled: PropTypes.bool,
};

SelectableDropdown.defaultProps = {
  loading: false,
  error: false,
  showTitle: true,
  isDisabled: false,
};


export default SelectableDropdown;
