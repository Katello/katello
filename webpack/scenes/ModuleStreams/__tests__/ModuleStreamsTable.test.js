import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import ModuleStreamsTable from '../ModuleStreamsTable';
import { Table } from '../../../move_to_foreman/components/common/table';

jest.mock('../../../move_to_foreman/foreman_toast_notifications');
jest.mock('foremanReact/components/Pagination/PaginationWrapper', () => (<div>Pagination Mock</div>));

describe('Module streams table', () => {
  it('should render and contain appropiate components', async () => {
    const moduleStreams = {
      loading: false, results: [], pagination: {}, itemCount: 0,
    };
    const onPaginationChange = () => {};

    const wrapper = shallow(<ModuleStreamsTable
      moduleStreams={moduleStreams}
      onPaginationChange={onPaginationChange}
    />);

    expect(toJson(wrapper)).toMatchSnapshot();
    expect(wrapper.find(Table)).toHaveLength(1);
  });
});

