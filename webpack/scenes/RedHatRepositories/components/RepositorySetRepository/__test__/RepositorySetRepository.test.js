import React from 'react';
import thunk from 'redux-thunk';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import configureMockStore from 'redux-mock-store';
import RepositorySetRepository from '../RepositorySetRepository';

jest.mock('../../../../../move_to_foreman/foreman_toast_notifications');

const mockStore = configureMockStore([thunk]);
const store = mockStore({});

describe('RepositorySetRepository Component', () => {
  let shallowWrapper;
  beforeEach(() => {
    shallowWrapper = shallow(<RepositorySetRepository
      store={store}
      contentId={1}
      productId={1}
      label="some label"
      displayArch="foo"
      releaseVer="1.1.1"
      type="foo"
      enabledPagination={{}}
      setRepositoryEnabled={() => {}}
      loadEnabledRepos={() => {}}
      enableRepository={() => {}}
    />);
  });

  afterEach(() => {
    store.clearActions();
  });

  it('should render', async () => {
    expect(toJson(shallowWrapper)).toMatchSnapshot();
  });
});
