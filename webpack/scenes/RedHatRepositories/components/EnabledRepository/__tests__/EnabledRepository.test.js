import React from 'react';
import thunk from 'redux-thunk';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import configureMockStore from 'redux-mock-store';
import EnabledRepository from '../EnabledRepository';

const mockStore = configureMockStore([thunk]);
const store = mockStore({});

describe('Enabled Repositories Component', () => {
  let shallowWrapper;
  beforeEach(() => {
    shallowWrapper = shallow(<EnabledRepository
      store={store}
      id={1}
      contentId={1}
      productId={1}
      name="foo"
      orphaned={false}
      type="foo"
      arch="foo"
      releaseVer="1.1.1"
      label="some label"
      pagination={{}}
      setRepositoryDisabled={() => {}}
      loadEnabledRepos={() => {}}
      disableRepository={() => {}}
    />);
  });

  afterEach(() => {
    store.clearActions();
  });

  it('should render', async () => {
    expect(toJson(shallowWrapper)).toMatchSnapshot();
  });
});

