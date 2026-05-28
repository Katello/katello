import React, { useState, useRef, useMemo, useCallback, memo } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Menu,
  MenuContent,
  MenuList,
  MenuItem,
  MenuToggle,
  Popper,
  Badge,
  MenuSearch,
  SearchInput,
  Divider,
  Spinner,
} from '@patternfly/react-core';
import './MultiSelect.scss';

// Memoized menu item to prevent re-renders when other items change
const MemoizedMenuItem = memo(({
  itemId, isSelected, label,
}) => (
  <MenuItem
    itemId={itemId}
    hasCheckbox
    isSelected={isSelected}
  >
    {label}
  </MenuItem>
));

MemoizedMenuItem.propTypes = {
  itemId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  isSelected: PropTypes.bool.isRequired,
  label: PropTypes.string.isRequired,
};

function MultiSelect(props) {
  const {
    options,
    onChange,
    defaultValues,
    noneSelectedText,
    maxItemsCountForFullLabel,
    className,
    ouiaId,
    isLoading,
    searchable,
  } = props;

  const [isOpen, setIsOpen] = useState(false);
  const [selected, setSelected] = useState(defaultValues || []);
  const [searchValue, setSearchValue] = useState('');
  const toggleRef = useRef(null);
  const menuRef = useRef(null);
  const searchInputRef = useRef(null);

  const handleSelect = useCallback((_event, value) => {
    let newSelected;
    setSelected((prevSelected) => {
      newSelected = prevSelected.includes(value)
        ? prevSelected.filter(item => item !== value)
        : [...prevSelected, value];
      return newSelected;
    });
    setTimeout(() => onChange(newSelected), 0);
  }, [onChange]);

  const handleSearchChange = useCallback((_event, value) => {
    setSearchValue(value);
  }, []);

  // Memoize filtered options to prevent recalculation on every render
  const filteredOptions = useMemo(() => {
    if (!searchable || !searchValue) return options;
    const lowerSearch = searchValue.toLowerCase();
    return options.filter(option =>
      option.label.toLowerCase().includes(lowerSearch));
  }, [options, searchValue, searchable]);

  // Memoize toggle display text calculation
  const toggleText = useMemo(() => {
    if (selected.length === 0 || selected.length > maxItemsCountForFullLabel) {
      return noneSelectedText;
    }
    // Show individual labels when count is low
    const labels = selected.map((val) => {
      const option = options.find(opt => opt.value === val);
      return option ? option.label : val;
    });
    return labels.join(', ');
  }, [selected, options, maxItemsCountForFullLabel, noneSelectedText]);

  const toggle = (
    <MenuToggle
      ref={toggleRef}
      onClick={() => setIsOpen(!isOpen)}
      isExpanded={isOpen}
      isFullWidth
      isDisabled={isLoading}
      {...(selected.length > 0 && {
        badge: selected.length > maxItemsCountForFullLabel ? (
          <Badge isRead>{selected.length}</Badge>
        ) : null,
      })}
      ouiaId={ouiaId}
      icon={isLoading ? <Spinner size="md" /> : null}
    >
      {isLoading ? __('Loading...') : toggleText}
    </MenuToggle>
  );

  const menu = (
    <Menu
      ref={menuRef}
      onSelect={handleSelect}
      selected={selected}
      ouiaId={`${ouiaId}-menu`}
      className="pf-multiselect-scrollable-menu"
    >
      {searchable && (
        <>
          <MenuSearch>
            <SearchInput
              ref={searchInputRef}
              value={searchValue}
              onChange={handleSearchChange}
              placeholder={__('Search')}
              aria-label={__('Search')}
            />
          </MenuSearch>
          <Divider />
        </>
      )}
      <MenuContent>
        <MenuList>
          {filteredOptions.length === 0 ? (
            <MenuItem isDisabled>{__('No results found')}</MenuItem>
          ) : (
            filteredOptions.map(option => (
              <MemoizedMenuItem
                key={`option-${option.value}`}
                itemId={option.value}
                isSelected={selected.includes(option.value)}
                label={option.label}
              />
            ))
          )}
        </MenuList>
      </MenuContent>
    </Menu>
  );

  return (
    <div className={className}>
      <Popper
        trigger={toggle}
        popper={menu}
        isVisible={isOpen}
        appendTo={() => document.body}
        popperMatchesTriggerWidth={false}
        onDocumentClick={(event) => {
          if (
            toggleRef.current &&
            !toggleRef.current.contains(event.target) &&
            menuRef.current &&
            !menuRef.current.contains(event.target)
          ) {
            setIsOpen(false);
          }
        }}
      />
    </div>
  );
}

MultiSelect.defaultProps = {
  onChange: () => { },
  defaultValues: null,
  noneSelectedText: __('Nothing selected'),
  maxItemsCountForFullLabel: 3,
  className: '',
  ouiaId: undefined,
  isLoading: false,
  searchable: false,
};

MultiSelect.propTypes = {
  options: PropTypes.arrayOf(PropTypes.shape({
    value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
    label: PropTypes.string.isRequired,
  })).isRequired,
  onChange: PropTypes.func,
  defaultValues: PropTypes.arrayOf(PropTypes.oneOfType([PropTypes.string, PropTypes.number])),
  noneSelectedText: PropTypes.string,
  maxItemsCountForFullLabel: PropTypes.number,
  className: PropTypes.string,
  ouiaId: PropTypes.string,
  isLoading: PropTypes.bool,
  searchable: PropTypes.bool,
};

export default MultiSelect;
