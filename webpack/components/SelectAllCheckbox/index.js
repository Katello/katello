import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import {
  Dropdown,
  DropdownToggle,
  DropdownToggleCheckbox,
  DropdownItem,
} from '@patternfly/react-core/deprecated';
import { translate as __ } from 'foremanReact/common/I18n';
import { noop } from 'foremanReact/common/helpers';

import './SelectAllCheckbox.scss';

const SelectAllCheckbox = ({
  selectNone,
  selectPage,
  selectedCount,
  pageRowCount,
  totalCount,
  areAllRowsOnPageSelected,
  areAllRowsSelected,
  selectAll,
}) => {
  const [isSelectAllDropdownOpen, setSelectAllDropdownOpen] = useState(false);
  const [selectionToggle, setSelectionToggle] = useState(false);

  const canSelectAll = selectAll !== noop;

  // Checkbox states: false = unchecked, null = partially-checked, true = checked
  // Flow: All are selected -> click -> none are selected
  // Some are selected -> click -> none are selected
  // None are selected -> click -> page is selected
  const onSelectAllCheckboxChange = (checked) => {
    if (checked && selectionToggle !== null) {
      if (!canSelectAll) {
        selectPage();
      } else {
        selectAll(true);
      }
    } else {
      selectNone();
    }
  };

  const onSelectAllDropdownToggle = () => setSelectAllDropdownOpen(isOpen => !isOpen);

  const handleSelectAll = () => {
    setSelectAllDropdownOpen(false);
    setSelectionToggle(true);
    selectAll(true);
  };
  const handleSelectPage = () => {
    setSelectAllDropdownOpen(false);
    setSelectionToggle(true);
    selectPage();
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
    <DropdownItem key="select-none" ouiaId="select-none" component="button" isDisabled={selectedCount === 0} onClick={handleSelectNone} >
      {`${__('Select none')} (0)`}
    </DropdownItem>,
    <DropdownItem key="select-page" ouiaId="select-page" component="button" isDisabled={pageRowCount === 0 || areAllRowsOnPageSelected} onClick={handleSelectPage}>
      {`${__('Select page')} (${pageRowCount})`}
    </DropdownItem>,
  ];
  if (canSelectAll) {
    selectAllDropdownItems.push((
      <DropdownItem key="select-all" id="all" ouiaId="select-all" component="button" isDisabled={totalCount === 0 || areAllRowsSelected} onClick={handleSelectAll}>
        {`${__('Select all')} (${totalCount})`}
      </DropdownItem>));
  }

  return (
    <Dropdown
      toggle={
        <DropdownToggle
          onToggle={onSelectAllDropdownToggle}
          id="select-all-checkbox-dropdown-toggle"
          ouiaId="select-all-checkbox-dropdown-toggle"
          splitButtonItems={[
            <DropdownToggleCheckbox
              className="tablewrapper-select-all-checkbox"
              key="tablewrapper-select-all-checkbox"
              ouiaId="select-all-checkbox-dropdown-toggle-checkbox"
              aria-label="Select all"
              onChange={(_event, checked) => onSelectAllCheckboxChange(checked)}
              isChecked={selectionToggle}
              isDisabled={totalCount === 0 && selectedCount === 0}
            >
              {selectedCount > 0 && `${selectedCount} selected`}
            </DropdownToggleCheckbox>,
          ]}
        />
      }
      isOpen={isSelectAllDropdownOpen}
      dropdownItems={selectAllDropdownItems}
      id="selection-checkbox"
      ouiaId="selection-checkbox"
    />
  );
};

SelectAllCheckbox.propTypes = {
  selectedCount: PropTypes.number.isRequired,
  selectNone: PropTypes.func.isRequired,
  selectPage: PropTypes.func.isRequired,
  selectAll: PropTypes.func,
  pageRowCount: PropTypes.number.isRequired,
  totalCount: PropTypes.number.isRequired,
  areAllRowsOnPageSelected: PropTypes.bool.isRequired,
  areAllRowsSelected: PropTypes.bool.isRequired,
};

SelectAllCheckbox.defaultProps = {
  selectAll: noop,
};

export default SelectAllCheckbox;
