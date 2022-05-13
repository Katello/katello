import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector, shallowEqual } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { Dropdown, DropdownItem, DropdownToggle, DropdownSeparator } from '@patternfly/react-core';
import { OutlinedBookmarkIcon } from '@patternfly/react-icons';
import { getBookmarks } from './BookmarkActions';
import { selectBookmarks, selectBookmarkStatus } from './BookmarkSelectors';
import './Bookmark.scss';
import AddBookmarkModal from './AddBookmarkModal';

const Bookmark = ({
  selectItem, selectedItem, controller = '', isDisabled, readOnlyBookmarks,
}) => {
  const dispatch = useDispatch();
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [modalOpen, setModalOpen] = useState(false);
  const { results = [] } =
    useSelector(state => selectBookmarks(state, controller), shallowEqual);
  const status =
    useSelector(state => selectBookmarkStatus(state, controller), shallowEqual);
  const showActions = !readOnlyBookmarks;

  useEffect(() => {
    dispatch(getBookmarks(controller));
  }, [controller, dispatch]);

  const setSelectItem = (query) => {
    if (selectedItem !== query) {
      selectItem(query);
    }
    setDropdownOpen(false);
  };
  if (!results.length && readOnlyBookmarks) return null;

  const dropDownItems = [
    ...results.map(({ name, id, query }) => (
      <DropdownItem
        onClick={() => setSelectItem(query)}
        key={id}
        tooltip={query}
      >
        {name}
      </DropdownItem >)),
  ];
  if (showActions) {
    dropDownItems.push(
      <DropdownSeparator key="separator" />,
      <DropdownItem
        onClick={() => {
          setDropdownOpen(false);
          setModalOpen(true);
        }}
        key="ADD_BOOKMARK"
      >
        {selectedItem ? __('Bookmark this search') : __('Add new bookmark')}
      </DropdownItem >,
    );
  }


  return (
    <>
      <Dropdown
        aria-label="bookmark-dropdown"
        toggle={
          <DropdownToggle
            isDisabled={isDisabled || status !== STATUS.RESOLVED}
            onToggle={setDropdownOpen}
            id="toggle-id"
          >
            <OutlinedBookmarkIcon />
          </DropdownToggle>
        }
        isOpen={dropdownOpen}
        dropdownItems={dropDownItems}
      />
      {modalOpen &&
        <AddBookmarkModal
          selectedItem={selectedItem}
          controller={controller}
          onClose={() => setModalOpen(false)}
        />}
    </>
  );
};

Bookmark.propTypes = {
  isDisabled: PropTypes.bool,
  controller: PropTypes.string.isRequired,
  selectItem: PropTypes.func.isRequired,
  selectedItem: PropTypes.string.isRequired,
  readOnlyBookmarks: PropTypes.bool,
};

Bookmark.defaultProps = {
  isDisabled: undefined,
  readOnlyBookmarks: false,
};

export default Bookmark;
