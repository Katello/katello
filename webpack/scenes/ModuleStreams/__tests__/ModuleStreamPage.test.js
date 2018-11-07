import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import ModuleStreamsPage from '../ModuleStreamsPage';
import ModuleStreamsTable from '../ModuleStreamsTable';
import Search from '../../../components/Search/index';

jest.mock('../../../move_to_foreman/foreman_toast_notifications');
jest.mock('foremanReact/components/Pagination/PaginationWrapper', () => (<div>Pagination Mock</div>));

describe('Module streams page', () => {
  it('should render and contain appropiate components', async () => {
    const moduleStreams = {};
    const mockLocation = { search: '' };
    const getModuleStreams = () => {};

    const wrapper = shallow(<ModuleStreamsPage
      moduleStreams={moduleStreams}
      getModuleStreams={getModuleStreams}
      location={mockLocation}
    />);

    expect(toJson(wrapper)).toMatchSnapshot();
    expect(wrapper.find(ModuleStreamsTable)).toHaveLength(1);
    expect(wrapper.find(Search)).toHaveLength(1);
  });
});

