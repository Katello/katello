import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import SearchBar from 'foremanReact/components/SearchBar';
import ContentPage from '../ContentPage';
import ContentTable from '../ContentTable';

describe('Content page', () => {
  it('should render and contain appropriate components', async () => {
    const contentHeader = 'Content Header';
    const content = {};
    const onSearch = () => {};
    const updateSearchQuery = () => {};
    const searchQuery = '';
    const onPaginationChange = () => {};
    const TableSchema = [];

    const wrapper = shallow(<ContentPage
      header={contentHeader}
      content={content}
      tableSchema={TableSchema}
      onSearch={onSearch}
      updateSearchQuery={updateSearchQuery}
      initialInputValue={searchQuery}
      onPaginationChange={onPaginationChange}
    />);

    expect(toJson(wrapper)).toMatchSnapshot();
    expect(wrapper.find(ContentTable)).toHaveLength(1);
    expect(wrapper.find(SearchBar)).toHaveLength(1);
  });
});
