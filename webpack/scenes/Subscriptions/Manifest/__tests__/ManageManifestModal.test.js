import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import ManageManifestModal from '../ManageManifestModal';
import { manifestHistorySuccessState } from './manifest.fixtures';

jest.mock('foremanReact/components/Pagination/PaginationWrapper', () => (<div>Pagination Mock</div>));
jest.mock('foremanReact/components/ForemanModal');

describe('manage manifest modal', () => {
  const noop = jest.fn();
  const organization = { id: 1, redhat_repository_url: 'https://redhat.com' };

  it('should render', () => {
    const page = shallow(<ManageManifestModal
      setModalOpen={noop}
      setModalClosed={noop}
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
    />);
    expect(toJson(page)).toMatchSnapshot();
  });
});
