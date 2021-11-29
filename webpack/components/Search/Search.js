import React, { useState, useEffect, useRef } from 'react';
import { useDispatch } from 'react-redux';
import { ControlLabel } from 'react-bootstrap';
import { loadSetting } from 'foremanReact/components/Settings/SettingsActions';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import TypeAhead from '../TypeAhead';
import api, { foremanApi } from '../../services/api';
import { stringIncludes } from './helpers';
import {
  AUTOSEARCH_DELAY,
  AUTOSEARCH_WHILE_TYPING,
} from '../../scenes/Settings/SettingsConstants';

const Search = ({
  onSearch,
  updateSearchQuery,
  isDisabled,
  settings: { autoSearchDelay },
  initialInputValue,
  patternfly4,
  settings: { autoSearchEnabled },
  getAutoCompleteParams,
  foremanApiAutoComplete,
  bookmarkController,
}) => {
  const [items, setItems] = useState([]);
  const dispatch = useDispatch();
  const mountedRef = useRef(true);

  const onInputUpdate = async (searchTerm = '') => {
    const newItems = items.filter(({ text }) => stringIncludes(text, searchTerm));

    if (newItems.length !== items.length) {
      // Checking whether the current component is mounted before state change events
      if (!mountedRef.current) return;
      setItems(newItems);
    }

    const { params, endpoint } = getAutoCompleteParams(searchTerm);

    if (endpoint) {
      let data;
      if (foremanApiAutoComplete) {
        data = await foremanApi.get(endpoint, undefined, params);
      } else {
        data = await api.get(endpoint, undefined, params);
      }
      // Checking whether the current component is mounted before state change events
      if (!mountedRef.current) return;
      setItems(data?.data?.filter(({ error }) => !error).map(({ label }) => ({
        text: label.trim(),
      })));
    }

    if (autoSearchEnabled && patternfly4) {
      onSearch(searchTerm || '');
    }
  };

  useEffect(() => {
    dispatch(loadSetting(AUTOSEARCH_DELAY));
    dispatch(loadSetting(AUTOSEARCH_WHILE_TYPING));
    return () => { mountedRef.current = false; };
  }, [dispatch]);

  const onNewSearch = (search) => {
    if (updateSearchQuery) updateSearchQuery(search);
    onSearch(search);
  };

  return (
    <div>
      <ControlLabel srOnly>{__('Search')}</ControlLabel>
      <TypeAhead
        autoSearchDelay={autoSearchDelay}
        bookmarkController={bookmarkController}
        isDisabled={isDisabled}
        items={items}
        onInputUpdate={onInputUpdate}
        onSearch={onNewSearch}
        initialInputValue={initialInputValue}
        patternfly4={patternfly4}
        autoSearchEnabled={autoSearchEnabled}
      />
    </div>
  );
};

Search.propTypes = {
  onSearch: PropTypes.func.isRequired,
  getAutoCompleteParams: PropTypes.func.isRequired,
  foremanApiAutoComplete: PropTypes.bool,
  updateSearchQuery: PropTypes.func,
  initialInputValue: PropTypes.string,
  patternfly4: PropTypes.bool,
  isDisabled: PropTypes.bool,
  settings: PropTypes.shape({
    autoSearchEnabled: PropTypes.bool,
    autoSearchDelay: PropTypes.number,
  }),
  bookmarkController: PropTypes.string,
};

Search.defaultProps = {
  updateSearchQuery: undefined,
  foremanApiAutoComplete: false,
  initialInputValue: '',
  patternfly4: false,
  settings: {
    autoSearchEnabled: true,
  },
  isDisabled: undefined,
  bookmarkController: undefined,
};

export default Search;
