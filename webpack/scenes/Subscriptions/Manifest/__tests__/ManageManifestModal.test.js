import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import ManageManifestModal from '../ManageManifestModal';
import { manifestHistorySuccessState } from './manifest.fixtures';

jest.mock('foremanReact/components/Pagination/PaginationWrapper', () => (<div>Pagination Mock</div>));

describe('manage manifest modal', () => {
  const noop = () => { };
  const organization = { id: 1, redhat_repository_url: 'https://redhat.com' };

  it('should render', async () => {
    const page = shallow(<ManageManifestModal
      upload={noop}
      refresh={noop}
      delete={noop}
      loadManifestHistory={noop}
      organization={organization}
      loadOrganization={noop}
      saveOrganization={noop}
      bulkSearch={noop}
      manifestHistory={manifestHistorySuccessState}
      taskInProgress={false}
      showModal
    />);
    expect(toJson(page)).toMatchSnapshot();
  });
});
