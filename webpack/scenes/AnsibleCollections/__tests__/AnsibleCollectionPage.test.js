import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import AnsibleCollectionsPage from '../AnsibleCollectionsPage';
import ContentPage from '../../../components/Content/ContentPage';

jest.mock('foremanReact/components/Pagination/PaginationWrapper', () => (<div>Pagination Mock</div>));

describe('Ansible Collections page', () => {
  it('should render and contain appropiate components', async () => {
    const ansibleCollections = {};
    const mockLocation = { search: '' };
    const getAnsibleCollections = () => {};

    const wrapper = shallow(<AnsibleCollectionsPage
      ansibleCollections={ansibleCollections}
      getAnsibleCollections={getAnsibleCollections}
      location={mockLocation}
    />);

    expect(toJson(wrapper)).toMatchSnapshot();
    expect(wrapper.find(ContentPage)).toHaveLength(1);
  });
});

