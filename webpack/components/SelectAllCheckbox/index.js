import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { Dropdown, DropdownToggle, DropdownToggleCheckbox,
  DropdownItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { noop } from 'foremanReact/common/helpers';

import { pluralize } from '../../utils/helpers';
import './SelectAllCheckbox.scss';

const SelectAllCheckbox = ({
  selectAll,
  selectNone,
  selectPage,
  selectedCount,
  modelName,
  modelNamePlural,
  areAllRowsOnPageSelected,
  areAllRowsSelected,
}) => {
  const [isSelectAllChecked, setSelectAllChecked] = useState(null);
  const [isSelectAllDropdownOpen, setSelectAllDropdownOpen] = useState(false);

  const onSelectAllCheckboxChange = () => {
    if (isSelectAllChecked === false) {
      return selectPage();
    }
    return selectNone();
  };
  const onSelectAllDropdownToggle = () => setSelectAllDropdownOpen(isOpen => !isOpen);
  const pluralizedModel = pluralize(
    selectedCount,
    modelName,
    modelNamePlural,
  );

  const handleSelectAll = () => {
    selectAll();
    setSelectAllDropdownOpen(false);
  };
  const handleSelectPage = () => {
    selectPage();
    setSelectAllDropdownOpen(false);
  };
  const handleSelectNone = () => {
    selectNone();
    setSelectAllDropdownOpen(false);
  };

  useEffect(() => {
    let newCheckedState;
    if (selectedCount === 0) newCheckedState = false;
    if (selectedCount > 0) newCheckedState = null; // null is partially-checked state
    if (areAllRowsSelected) newCheckedState = true;
    setSelectAllChecked(newCheckedState);
  }, [selectedCount, areAllRowsSelected]);

  const selectAllDropdownItems = [
    <DropdownItem key="select-all" component="button" isDisabled onClick={handleSelectAll}>
      {__('Select all')}
    </DropdownItem>,
    <DropdownItem key="select-page" component="button" isDisabled={areAllRowsOnPageSelected} onClick={handleSelectPage}>
      {__('Select page')}
    </DropdownItem>,
    <DropdownItem key="select-none" component="button" onClick={handleSelectNone}>
      {__('Select none')}
    </DropdownItem>,
  ];

  return (
    <Dropdown
      toggle={
        <DropdownToggle
          onToggle={onSelectAllDropdownToggle}
          id="toggle-id-8"
          splitButtonItems={[
            <DropdownToggleCheckbox
              className="tablewrapper-select-all-checkbox"
              key="tablewrapper-select-all-checkbox"
              aria-label="Select all"
              onChange={checked => onSelectAllCheckboxChange(checked)}
              isChecked={isSelectAllChecked}
            >
              {`${pluralizedModel} selected`}
            </DropdownToggleCheckbox>,
          ]}
        />
    }
      isOpen={isSelectAllDropdownOpen}
      dropdownItems={selectAllDropdownItems}
    />
  );
};

SelectAllCheckbox.propTypes = {
  selectedCount: PropTypes.number,
  modelName: PropTypes.string,
  modelNamePlural: PropTypes.string,
  selectAll: PropTypes.func,
  selectNone: PropTypes.func,
  selectPage: PropTypes.func,
  areAllRowsSelected: PropTypes.bool,
  areAllRowsOnPageSelected: PropTypes.bool,
};

SelectAllCheckbox.defaultProps = {
  selectedCount: 0,
  modelName: 'item',
  modelNamePlural: undefined,
  selectAll: noop,
  selectNone: noop,
  selectPage: noop,
  areAllRowsSelected: false,
  areAllRowsOnPageSelected: false,
};

export default SelectAllCheckbox;
