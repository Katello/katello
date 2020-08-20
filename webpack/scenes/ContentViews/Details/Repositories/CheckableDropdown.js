import React, { useState, Fragment } from 'react';
import PropTypes from 'prop-types';
import {
  Dropdown,
  DropdownToggle,
  DropdownItem,
  Split,
  SplitItem,
  Checkbox,
} from '@patternfly/react-core';
import CaretDownIcon from '@patternfly/react-icons';

const CheckableDropdown = ({
  items, title, checked, setChecked,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const onSelect = () => {};
  const onToggle = open => setIsOpen(open);

  // Should the whole item be clickable or just the checkbox? (probably)
  const checkableDropwdownItems = items.map(item => (
    <DropdownItem key={`${item}-split`} component="button" style={{ minWidth: '200px' }}>
      <Split>
        <SplitItem>
          <Checkbox
            aria-label={`${item} checkbox`}
            isChecked={checked[item]}
            onChange={check => setChecked({ ...checked, [item]: check })}
            id={`${item}-checkbox`}
          />
        </SplitItem>
        <SplitItem>
          {item}
        </SplitItem>
      </Split>
    </DropdownItem>
  ));

  return (
    <Fragment>
      <Dropdown
        onSelect={onSelect}
        key="type-dropdown"
        toggle={
          <DropdownToggle aria-label={`toggle ${title}`} id="toggle-id" onToggle={onToggle} toggleIndicator={CaretDownIcon}>
            {title}
          </DropdownToggle>
        }
        isOpen={isOpen}
        dropdownItems={checkableDropwdownItems}
      />
    </Fragment>
  );
};

CheckableDropdown.propTypes = {
  items: PropTypes.arrayOf(PropTypes.string).isRequired,
  title: PropTypes.string.isRequired,
  checked: PropTypes.shape({}).isRequired,
  setChecked: PropTypes.func.isRequired,
};


export default CheckableDropdown;
