import React from 'react';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import { mount } from 'enzyme';
import toJson from 'enzyme-to-json';
import withOrganization from './withOrganization';

jest.mock('../SelectOrg/SetOrganization');
const mockStore = configureMockStore([thunk]);
const store = mockStore({ katello: { organization: {} } });

describe('subscriptions page', () => {
  const WrappedComponent = () => <div> Wrapped! </div>;

  it('should render the wrapped component', () => {
    global.document.getElementById = () => ({ dataset: { id: 1 } });

    const Component = withOrganization(WrappedComponent);
    const page = mount(<Component store={store} />);
    expect(toJson(page)).toMatchSnapshot();
  });

  it('should render select org page', () => {
    global.document.getElementById = () => ({ dataset: { id: '' } });

    const Component = withOrganization(WrappedComponent);
    const page = mount(<Component store={store} />);
    expect(toJson(page)).toMatchSnapshot();
  });
});
