import React from 'react';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import ActivationKeysSearch from './index';

describe('ActivationKeysSearch', () => {
  let orgSelect;

  beforeEach(() => {
    orgSelect = document.createElement('select');
    orgSelect.id = 'hostgroup_organization_ids';
    const option = document.createElement('option');
    option.value = '1';
    option.selected = true;
    orgSelect.appendChild(option);
    document.body.appendChild(orgSelect);
  });

  afterEach(() => {
    orgSelect.remove();
  });
  it('renders without crashing', () => {
    const { getByText } = renderWithRedux(<ActivationKeysSearch />, {});
    expect(getByText('Activation Key information')).toBeInTheDocument();
  });
});
