import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import ContentTable from '../../../components/Content/ContentTable';
import TableSchema from '../../ModuleStreams/ModuleStreamsTableSchema';
import { Table } from '../../../move_to_foreman/components/common/table';

jest.mock('foremanReact/components/Pagination/PaginationWrapper', () => (<div>Pagination Mock</div>));

describe('Module streams table', () => {
  it('should render and contain appropiate components', async () => {
    const moduleStreams = {
      loading: false, results: [], pagination: {}, itemCount: 0,
    };
    const onPaginationChange = () => {};

    const wrapper = shallow(<ContentTable
      content={moduleStreams}
      tableSchema={TableSchema}
      onPaginationChange={onPaginationChange}
    />);

    expect(toJson(wrapper)).toMatchSnapshot();
    expect(wrapper.find(Table)).toHaveLength(1);
  });
});

