import React from 'react';
import { mount } from 'enzyme';
import toJson from 'enzyme-to-json';
import withOrganization from './withOrganization';

jest.mock('../SelectOrg/SetOrganization');

describe('subscriptions page', () => {
  const WrappedComponent = () => <div> Wrapped! </div>;

  it('should render the wrapped component', () => {
    global.document.getElementById = () => ({ dataset: { id: 1 } });

    const Component = withOrganization(WrappedComponent, '/test');
    const page = mount(<Component />);
    expect(toJson(page)).toMatchSnapshot();
  });

  it('should render select org page', () => {
    global.document.getElementById = () => ({ dataset: { id: '' } });

    const Component = withOrganization(WrappedComponent, '/test');
    const page = mount(<Component />);
    expect(toJson(page)).toMatchSnapshot();
  });
});
