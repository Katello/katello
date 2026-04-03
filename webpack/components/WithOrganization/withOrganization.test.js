import React from 'react';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import withOrganization from './withOrganization';

jest.mock('../SelectOrg/SetOrganization', () => {
  const React = require('react'); // eslint-disable-line global-require, no-shadow
  const Immutable = require('seamless-immutable'); // eslint-disable-line global-require
  const initialState = Immutable({ loading: false });
  const MockSetOrganization = () => <div>Set Organization Mock</div>;
  MockSetOrganization.displayName = 'SetOrganization';
  return {
    __esModule: true,
    default: MockSetOrganization,
    setOrganization: (state = initialState, _action) => state,
  };
});

describe('withOrganization', () => {
  const WrappedComponent = () => <div>Wrapped!</div>;

  it('should render the wrapped component when org is selected', () => {
    global.document.getElementById = () => ({ dataset: { id: 1 } });

    const Component = withOrganization(WrappedComponent);
    const { getByText } = renderWithRedux(<Component />);
    expect(getByText('Wrapped!')).toBeInTheDocument();
  });

  it('should render select org page when no org is selected', () => {
    global.document.getElementById = () => ({ dataset: { id: '' } });

    const Component = withOrganization(WrappedComponent);
    const { getByText, queryByText } = renderWithRedux(<Component />);
    expect(getByText('Set Organization Mock')).toBeInTheDocument();
    expect(queryByText('Wrapped!')).not.toBeInTheDocument();
  });
});
