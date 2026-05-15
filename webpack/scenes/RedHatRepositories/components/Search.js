/* eslint-disable import/no-extraneous-dependencies */
import React, { useState, useCallback, useMemo, useRef } from 'react';
import PropTypes from 'prop-types';
import {
  Menu,
  MenuContent,
  MenuList,
  MenuItem,
  MenuToggle,
  Popper,
} from '@patternfly/react-core';
import SearchBar from 'foremanReact/components/SearchBar';
import { translate as __ } from 'foremanReact/common/I18n';
import { orgId } from '../../../services/api';

const RepositorySearch = ({ onSearch, onSelectSearchList }) => {
  const dropDownItems = useMemo(() => [
    {
      key: 'available',
      endpoint: 'repository_sets',
      title: __('Available'),
    },
    {
      key: 'enabled',
      endpoint: 'enabled_repositories',
      title: __('Enabled'),
    },
    {
      key: 'both',
      endpoint: false,
      title: __('Both'),
    },
  ], []);

  const [searchList, setSearchList] = useState(dropDownItems[0]);
  const [isSelectOpen, setIsSelectOpen] = useState(false);
  const toggleRef = useRef(null);
  const menuRef = useRef(null);

  const handleSearch = useCallback((search) => {
    onSearch(search);
  }, [onSearch]);

  const handleSelectSearchList = useCallback((_event, selectedKey) => {
    const selected = dropDownItems.find(item => item.key === selectedKey);
    if (selected) {
      setSearchList(selected);
      onSelectSearchList(selected.key);
      setIsSelectOpen(false);
    }
  }, [dropDownItems, onSelectSearchList]);

  const getAutoCompleteEndpoint = useCallback(() => {
    if (searchList.key === 'enabled') {
      return '/katello/api/v2/repositories/auto_complete_search';
    } else if (searchList.key === 'available') {
      return '/katello/api/v2/repository_sets/auto_complete_search';
    }
    return '';
  }, [searchList.key]);

  const autocompleteQueryParams = useCallback(() => {
    const params = { organization_id: orgId() };
    if (searchList.key === 'enabled') {
      params.enabled = true;
    }
    return params;
  }, [searchList.key]);

  const toggle = (
    <MenuToggle
      ref={toggleRef}
      onClick={() => setIsSelectOpen(!isSelectOpen)}
      isExpanded={isSelectOpen}
      ouiaId="search-list-select"
    >
      {searchList.title}
    </MenuToggle>
  );

  const menu = (
    <Menu
      ref={menuRef}
      onSelect={handleSelectSearchList}
      selected={searchList.key}
      ouiaId="search-list-menu"
    >
      <MenuContent>
        <MenuList>
          {dropDownItems.map(({ key, title }) => (
            <MenuItem
              key={key}
              itemId={key}
              isSelected={searchList.key === key}
            >
              {title}
            </MenuItem>
          ))}
        </MenuList>
      </MenuContent>
    </Menu>
  );

  return (
    <>
      <div className="search-list-select-container">
        <Popper
          trigger={toggle}
          popper={menu}
          isVisible={isSelectOpen}
          appendTo={() => document.body}
          onDocumentClick={(event) => {
            if (
              toggleRef.current &&
              !toggleRef.current.contains(event.target) &&
              menuRef.current &&
              !menuRef.current.contains(event.target)
            ) {
              setIsSelectOpen(false);
            }
          }}
        />
      </div>
      <div className="search-input-container">
        <SearchBar
          data={{
            autocomplete: {
              url: getAutoCompleteEndpoint(),
              apiParams: autocompleteQueryParams(),
            },
            bookmarks: {},
          }}
          onSearch={handleSearch}
        />
      </div>
    </>
  );
};

RepositorySearch.propTypes = {
  onSearch: PropTypes.func.isRequired,
  onSelectSearchList: PropTypes.func.isRequired,
};

export default RepositorySearch;
