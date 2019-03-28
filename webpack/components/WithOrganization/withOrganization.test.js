import React from 'react';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import { mount } from 'enzyme';
import toJson from 'enzyme-to-json';
import withOrganization from './withOrganization';

jest.mock('../SelectOrg/SetOrganization');
const mockStore = configureMockStore([thunk]);
const orgInfo = { id: 1, title: 'Test' };
const anyOrgInfo = { title: 'Any Organization' };
describe('with organization', () => {
  const WrappedComponent = () => <div> Wrapped! </div>;
  const Component = withOrganization(WrappedComponent);
  const props = { location: {}, history: { push: jest.fn() } };

  it("should render a loading state when Katello org isn't loaded", () => {
    const store = mockStore({
      katello: { organization: {} },
      layout: { currentOrganization: orgInfo },
    });

    const page = mount(<Component store={store} {...props} />);
    expect(toJson(page)).toMatchSnapshot();
    expect(page.find('LoadingState')).toHaveLength(1);
  });

  it('should render a loading state when Katello org is still loading', () => {
    const store = mockStore({
      katello: { organization: { loading: true } },
      layout: { currentOrganization: orgInfo },
    });

    const page = mount(<Component store={store} {...props} />);
    expect(toJson(page)).toMatchSnapshot();
    expect(page.find('LoadingState')).toHaveLength(1);
  });


  it("should render the select org page when org is 'Any Organization'", () => {
    const store = mockStore({
      katello: { organization: {} },
      layout: { currentOrganization: anyOrgInfo },
    });

    const page = mount(<Component store={store} {...props} />);
    expect(toJson(page)).toMatchSnapshot();
    expect(page.find('Connect(withRouter(SetOrganization))')).toHaveLength(1);
  });

  it('should render the wrapped component when katello org is Loaded', () => {
    const store = mockStore({
      katello: { organization: orgInfo },
      layout: { currentOrganization: orgInfo },
    });

    const page = mount(<Component store={store} {...props} />);
    expect(toJson(page)).toMatchSnapshot();
    expect(page.find(WrappedComponent)).toHaveLength(1);
  });
});
