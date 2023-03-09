import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { SearchAutocomplete } from 'foremanReact/components/SearchBar/SearchAutocomplete';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { STATUS } from 'foremanReact/constants';
import { noop } from 'foremanReact/common/helpers';

const SearchText = ({
  data: {
    autocomplete: { url, apiParams } = { url: '' },
    disabled,
  },
  initialQuery,
  onSearchChange,
  name,
}) => {
  const [search, setSearch] = useState(initialQuery || '');
  const getAPIparams = input => ({ ...apiParams(input) });
  const { response, status, setAPIOptions } = useAPI('get', url, {
    params: getAPIparams(search),
  });
  const onChange = (newValue) => {
    onSearchChange(newValue);
    setSearch(newValue);
    setAPIOptions({ params: { ...getAPIparams(newValue) } });
  };
  const error =
    status === STATUS.ERROR || response?.[0]?.error
      ? response?.[0]?.error || response.message
      : null;

  let results = [];
  if (Array.isArray(response) && !error) {
    results = response.map(item => ({ label: item, category: '' }));
  }

  return (
    <div className="foreman-search-text">
      <SearchAutocomplete
        results={results}
        onSearchChange={onChange}
        value={search}
        disabled={disabled}
        error={error}
        name={name}
      />
    </div>
  );
};

SearchText.propTypes = {
  data: PropTypes.shape({
    autocomplete: PropTypes.shape({
      url: PropTypes.string.isRequired,
      apiParams: PropTypes.func,
    }).isRequired,
    disabled: PropTypes.bool,
  }).isRequired,
  initialQuery: PropTypes.string,
  onSearchChange: PropTypes.func,
  name: PropTypes.string,
};

SearchText.defaultProps = {
  initialQuery: '',
  onSearchChange: noop,
  name: null,
};

export default SearchText;
