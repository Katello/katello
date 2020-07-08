import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import ContentTable from '../../../components/Content/ContentTable';
import TableSchema from '../../AnsibleCollections/AnsibleCollectionsTableSchema';
import { Table } from '../../../components/pf3Table';

jest.mock('foremanReact/components/Pagination/PaginationWrapper', () => (<div>Pagination Mock</div>));

describe('Ansible Collections table', () => {
  it('should render and contain appropiate components', async () => {
    const ansibleCollections = {
      loading: false, results: [], pagination: {}, itemCount: 0,
    };
    const onPaginationChange = () => {};

    const wrapper = shallow(<ContentTable
      content={ansibleCollections}
      tableSchema={TableSchema}
      onPaginationChange={onPaginationChange}
    />);

    expect(toJson(wrapper)).toMatchSnapshot();
    expect(wrapper.find(Table)).toHaveLength(1);
  });
});

