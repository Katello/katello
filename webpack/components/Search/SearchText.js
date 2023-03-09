import React from 'react';
import Autocomplete from 'react-autocomplete';
import PropTypes from 'prop-types';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { STATUS } from 'foremanReact/constants';
import { noop } from 'foremanReact/common/helpers';
import './SearchText.css';

const SearchText = ({
  data: {
    autocomplete: { url, apiParams } = { url: '' },
  },
  onChange,
  onSelect,
  value,
}) => {
  const { response, status } = useAPI('get', url, { params: { ...apiParams } });
  const error =
    status === STATUS.ERROR || response?.[0]?.error
      ? response?.[0]?.error || response.message
      : null;

  const renderItemTitle = (item, input) => (
    item.toLowerCase().indexOf(input.toLowerCase()) !== -1
  );

  return (
    <div className="autocomplete-wrapper">
      <Autocomplete
        value={value}
        items={Array.isArray(response) && !response?.[0]?.error ? response : []}
        getItemValue={item => item}
        shouldItemRender={renderItemTitle}
        renderMenu={item => (
          <div className="dropdown">
            {item}
          </div>
        )}
        renderItem={(item, isHighlighted) =>
          (<div className={`item ${isHighlighted ? 'selected-item' : ''}`} key={`item-${item}`}>
            {item}
           </div>)
        }
        onChange={event => onChange(event.target.value)}
        onSelect={val => onSelect(val)}
        error={error}
      />
    </div>
  );
};

SearchText.propTypes = {
  data: PropTypes.shape({
    autocomplete: PropTypes.shape({
      url: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
  value: PropTypes.string.isRequired,
  onChange: PropTypes.func,
  onSelect: PropTypes.func,
};

SearchText.defaultProps = {
  onChange: noop,
  onSelect: noop,
};

export default SearchText;
