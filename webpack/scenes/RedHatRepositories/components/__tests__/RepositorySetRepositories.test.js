import React from 'react';
import thunk from 'redux-thunk';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import configureMockStore from 'redux-mock-store';
import RepositorySetRepositories from '../RepositorySetRepositories';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ katello: { redHatRepositories: { repositorySetRepositories: [] } } });

describe('RepositorySetRepositories Component', () => {
  let shallowWrapper;
  beforeEach(() => {
    shallowWrapper = shallow(<RepositorySetRepositories
      store={store}
      contentId={1}
      productId={2}
      type="foo"
    />);
  });

  it('sorts repos correctly', async () => {
    const repos = [
      { arch: 'x86_64', releasever: '5.11' },
      { arch: 'x86_64', releasever: '7Server' },
      { arch: 'x86_64', releasever: '7.10' },
      { arch: 'x86_64', releasever: '7.1' },
      { arch: 'i386', releasever: '5.11' },
      { arch: 'i386', releasever: '5Workstation' },
      { arch: 'x86_64', releasever: '7.11' }];

    const result = shallowWrapper.dive().instance().sortedRepos(repos);

    const expectedIndices = [1, 5, 6, 2, 3, 0, 4];

    expectedIndices.forEach((expected, i) => {
      expect(result[i]).toEqual(repos[expected]);
    });
  });

  it('should render', async () => {
    expect(toJson(shallowWrapper)).toMatchSnapshot();
  });
});
