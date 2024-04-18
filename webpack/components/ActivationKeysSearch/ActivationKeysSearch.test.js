import React from 'react';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import ActivationKeysSearch from './index';

describe('ActivationKeysSearch', () => {
  const mockQuerySelector = jest.spyOn(document, 'querySelector');
  mockQuerySelector.mockImplementation((selector) => {
    if (selector === '#hostgroup_lifecycle_environment_id') {
      return {
        options: [{}],
        selectedIndex: 0,
        value: '1',
      };
    }
    if (selector === '#hostgroup_content_view_id') {
      return {
        options: [{}],
        selectedIndex: 0,
        value: '2 ',
      };
    }
    return null;
  });
  it('renders without crashing', () => {
    const { getByText } = renderWithRedux(<ActivationKeysSearch />, {});
    expect(getByText('Activation Key information')).toBeInTheDocument();
  });
});
