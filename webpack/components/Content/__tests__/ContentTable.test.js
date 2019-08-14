import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import ContentTable from '../ContentTable';
import { Table } from '../../../move_to_foreman/components/common/table';
import { LoadingState } from '../../../move_to_pf/LoadingState';

jest.mock('foremanReact/components/Pagination/PaginationWrapper', () => (<div>Pagination Mock</div>));

describe('Content Table', () => {
  it('should render and contain appropriate components', async () => {
    const content = {
      loading: false,
      results: [
        {
          dummy_content_id: 1,
          dummy_content_name: 'dummy_name_1',
        },
        {
          dummy_content_id: 2,
          dummy_content_name: 'dummy_name_2',
        },
      ],
      pagination: {},
      itemCount: 2,
    };
    const onPaginationChange = () => {};
    const TableSchema = [];

    const wrapper = shallow(<ContentTable
      content={content}
      tableSchema={TableSchema}
      onPaginationChange={onPaginationChange}
    />);

    expect(toJson(wrapper)).toMatchSnapshot();
    expect(wrapper.find(Table)).toHaveLength(1);
    expect(wrapper.find(LoadingState)).toHaveLength(1);
  });
});
