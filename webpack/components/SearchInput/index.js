import React from 'react';

import { InputGroup, FormControl, DropdownButton, MenuItem } from 'react-bootstrap';

export default () => (
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
