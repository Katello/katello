import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import { RepositorySetRepositories } from '../RepositorySetRepositories';

describe('RepositorySetRepositories Component', () => {
  it('should render with sorted repos', async () => {
    const shallowWrapper = shallow(<RepositorySetRepositories
      loadRepositorySetRepos={() => null}
      contentId={1}
      productId={2}
      data={{
        loading: false,
        repositories: [
          { arch: 'x86_64', releasever: '5.11' },
          { arch: 'x86_64', releasever: '7Server' },
          { arch: 'x86_64', releasever: '7.10' },
          { arch: 'x86_64', releasever: '7.1' },
          { arch: 'i386', releasever: '5.11' },
          { arch: 'i386', releasever: '5Workstation' },
          { arch: 'x86_64', releasever: '7.11' }],
      }}
    />);

    expect(toJson(shallowWrapper)).toMatchSnapshot();
  });

  it('should render loading', async () => {
    const shallowWrapper = shallow(<RepositorySetRepositories
      loadRepositorySetRepos={() => null}
      contentId={1}
      productId={2}
      type="foo"
      data={{
        loading: true,
        repositories: [],
      }}
    />);

    expect(toJson(shallowWrapper)).toMatchSnapshot();
  });

  it('should render with error', async () => {
    const shallowWrapper = shallow(<RepositorySetRepositories
      loadRepositorySetRepos={() => null}
      contentId={1}
      productId={2}
      type="foo"
      data={{
        loading: false,
        repositories: [],
        error: {
          displayMessage: 'some error',
        },
      }}
    />);

    expect(toJson(shallowWrapper)).toMatchSnapshot();
  });
});
