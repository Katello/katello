import React from 'react';
import { act } from 'react-test-renderer';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { CONTENT_KEY } from '../../../scenes/Content/ContentConstants';
import GenericContentPage from '../GenericContentPage';

const renderOptions = () => ({
  apiNamespace: CONTENT_KEY,
});

test('Can render the basic component with no data', async (done) => {
  const contentHeader = 'Content Header';
  const content = { results: [] };
  const onSearch = jest.fn();
  const updateSearchQuery = jest.fn();
  const searchQuery = '';
  const onPaginationChange = jest.fn();
  const TableSchema = [];
  const bookmarkController = 'module_streams';

  const { getByText } = renderWithRedux(<GenericContentPage
    header={contentHeader}
    content={content}
    tableSchema={TableSchema}
    onSearch={onSearch}
    updateSearchQuery={updateSearchQuery}
    initialInputValue={searchQuery}
    onPaginationChange={onPaginationChange}
    bookmarkController={bookmarkController}
  />, renderOptions());

  await patientlyWaitFor(() =>
    expect(getByText(contentHeader)).toBeInTheDocument());
  act(done);
});
