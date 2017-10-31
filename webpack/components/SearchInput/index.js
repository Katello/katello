import React from 'react';
import PropTypes from 'prop-types';

import { InputGroup, FormControl, DropdownButton, MenuItem } from 'react-bootstrap';

function SearchInput(props) {
  return (
    <InputGroup>
      <DropdownButton
        componentClass={InputGroup.Button}
        id="search-dropdown-pre-addon"
        title="Name"
      />

      <FormControl type="text" />

      <DropdownButton
        componentClass={InputGroup.Button}
        id="search-dropdown-post-addon"
        title="Available"
      >
        <MenuItem key="1">Enabled</MenuItem>
      </DropdownButton>
    </InputGroup>
  );
}

SearchInput.propTypes = {
  item: PropTypes.any
};

export default SearchInput;
