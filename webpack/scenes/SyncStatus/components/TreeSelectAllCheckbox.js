import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import {
  Dropdown,
  DropdownToggle,
  DropdownToggleCheckbox,
  DropdownItem,
} from '@patternfly/react-core/deprecated';
import { translate as __ } from 'foremanReact/common/I18n';

const TreeSelectAllCheckbox = ({
  selectNone,
  selectAll,
  selectedCount,
  totalCount,
  areAllRowsSelected,
}) => {
  const [isSelectAllDropdownOpen, setSelectAllDropdownOpen] = useState(false);
  const [selectionToggle, setSelectionToggle] = useState(false);

  // Checkbox states: false = unchecked, null = partially-checked, true = checked
  // Flow: All are selected -> click -> none are selected
  // Some are selected -> click -> none are selected
  // None are selected -> click -> all are selected
  const onSelectAllCheckboxChange = (checked) => {
    if (checked && selectionToggle !== null) {
      selectAll();
    } else {
      selectNone();
    }
  };

  const onSelectAllDropdownToggle = () => setSelectAllDropdownOpen(isOpen => !isOpen);

  const handleSelectAll = () => {
    setSelectAllDropdownOpen(false);
    setSelectionToggle(true);
    selectAll();
  };

  const handleSelectNone = () => {
    setSelectAllDropdownOpen(false);
    setSelectionToggle(false);
    selectNone();
  };

  useEffect(() => {
    let newCheckedState = null; // null is partially-checked state

    if (areAllRowsSelected) {
      newCheckedState = true;
    } else if (selectedCount === 0) {
      newCheckedState = false;
    }
    setSelectionToggle(newCheckedState);
  }, [selectedCount, areAllRowsSelected]);

  const selectAllDropdownItems = [
    <DropdownItem
      key="select-none"
      ouiaId="select-none"
      component="button"
      isDisabled={selectedCount === 0}
      onClick={handleSelectNone}
    >
      {`${__('Select none')} (0)`}
    </DropdownItem>,
    <DropdownItem
      key="select-all"
      id="all"
      ouiaId="select-all"
      component="button"
      isDisabled={totalCount === 0 || areAllRowsSelected}
      onClick={handleSelectAll}
    >
      {`${__('Select all')} (${totalCount})`}
    </DropdownItem>,
  ];

  return (
    <Dropdown
      toggle={
        <DropdownToggle
          onToggle={onSelectAllDropdownToggle}
          id="tree-select-all-checkbox-dropdown-toggle"
          ouiaId="tree-select-all-checkbox-dropdown-toggle"
          splitButtonItems={[
            <DropdownToggleCheckbox
              className="tablewrapper-select-all-checkbox"
              key="tree-select-all-checkbox"
              ouiaId="tree-select-all-checkbox-dropdown-toggle-checkbox"
              aria-label="Select all"
              onChange={(_event, checked) => onSelectAllCheckboxChange(checked)}
              isChecked={selectionToggle}
              isDisabled={totalCount === 0 && selectedCount === 0}
            >
              {selectedCount > 0 ? `${selectedCount} selected` : '\u00A0'}
            </DropdownToggleCheckbox>,
          ]}
        />
      }
      isOpen={isSelectAllDropdownOpen}
      dropdownItems={selectAllDropdownItems}
      id="tree-selection-checkbox"
      ouiaId="tree-selection-checkbox"
    />
  );
};

TreeSelectAllCheckbox.propTypes = {
  selectedCount: PropTypes.number.isRequired,
  selectNone: PropTypes.func.isRequired,
  selectAll: PropTypes.func.isRequired,
  totalCount: PropTypes.number.isRequired,
  areAllRowsSelected: PropTypes.bool.isRequired,
};

export default TreeSelectAllCheckbox;
