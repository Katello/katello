import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { nockInstance } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import ContentRepositories from '../ContentRepositories';
import FileContentViewVersions from '../FileContentViewVersions';

const metadata = {
  total: 1, subtotal: 1, page: 1, per_page: 20,
};
const cases = [
  ['repositories', '/repositories', <ContentRepositories contentType="files" id={248} tabKey="repositories" />,
    {
      id: 1, name: 'Search test repository', content_type: 'file', product: { id: 2, name: 'Product' },
    }],
  ['content views', '/content_view_versions', <FileContentViewVersions id={248} />,
    { id: 1, version: '1.0', content_view: { id: 2, name: 'Search test view' } }],
];

test.each(cases)(
  '%s search submits with the button and Enter, and clears results',
  async (_label, path, component, row) => {
    const endpoint = api.getApiUrl(path);
    const autocomplete = nockInstance.get(`${endpoint}/auto_complete_search`)
      .query(true).optionally().times(20)
      .reply(200, []);
    const initial = nockInstance.get(endpoint).query(query => !query.search)
      .reply(200, { ...metadata, results: [row] });
    const {
      getByLabelText, getByRole, getByText, queryByRole,
    } = renderWithRedux(component);
    await patientlyWaitFor(() => expect(getByRole('button', { name: 'Search' })).toBeEnabled());
    expect(queryByRole('button', { name: /bookmark/i })).toBeNull();
    const input = getByLabelText('Search input');
    const query = 'name = "does-not-exist"';
    const searched = nockInstance.get(endpoint)
      .query(params => params.search === query && params.page === '1' &&
        params.file_id === '248' && params.organization_id !== undefined &&
        (path === '/repositories' || params.nondefault === 'true'))
      .reply(200, { ...metadata, subtotal: 0, results: [] });
    input.focus();
    fireEvent.change(input, { target: { value: query } });
    expect(searched.isDone()).toBe(false);
    fireEvent.click(getByRole('button', { name: 'Search' }));
    await patientlyWaitFor(() => expect(searched.isDone()).toBe(true));
    await patientlyWaitFor(() => expect(getByText(/No matching/)).toBeInTheDocument());

    const entered = nockInstance.get(endpoint).query(params => params.search === 'another-query')
      .reply(200, { ...metadata, subtotal: 0, results: [] });
    input.focus();
    fireEvent.change(input, { target: { value: 'another-query' } });
    fireEvent.keyDown(input, { key: 'Enter', code: 'Enter', charCode: 13 });
    await patientlyWaitFor(() => expect(entered.isDone()).toBe(true));

    const cleared = nockInstance.get(endpoint).query(params => !params.search)
      .reply(200, { ...metadata, results: [row] });
    fireEvent.click(getByRole('button', { name: 'Reset search' }));
    await patientlyWaitFor(() => expect(cleared.isDone()).toBe(true));
    await patientlyWaitFor(() => expect(getByLabelText('Search input')).toHaveValue(''));
    initial.done();
    searched.done();
    entered.done();
    cleared.done();
    autocomplete.done();
  },
);


test.each(cases)(
  '%s shows pagination for single-page and multi-page results',
  async (_label, path, component, row) => {
    const endpoint = api.getApiUrl(path);
    nockInstance.get(`${endpoint}/auto_complete_search`)
      .query(true).optionally().times(20)
      .reply(200, []);
    const initial = nockInstance.get(endpoint).query(true)
      .reply(200, { ...metadata, results: [row] });
    const { getByRole, getByLabelText, container } = renderWithRedux(component);
    await patientlyWaitFor(() => expect(getByRole('button', { name: 'Search' })).toBeEnabled());
    await patientlyWaitFor(() => {
      expect(container.querySelector('[data-ouia-component-id="pagination-top"]'))
        .toBeInTheDocument();
      expect(container.querySelector('[data-ouia-component-id="pagination-bottom"]'))
        .toBeInTheDocument();
    });

    const multiplePages = nockInstance.get(endpoint).query(params => params.search === 'many')
      .reply(200, {
        ...metadata, total: 21, subtotal: 21, results: [row],
      });
    const input = getByLabelText('Search input');
    input.focus();
    fireEvent.change(input, { target: { value: 'many' } });
    fireEvent.click(getByRole('button', { name: 'Search' }));
    await patientlyWaitFor(() => {
      expect(container.querySelector('[data-ouia-component-id="pagination-top"]'))
        .toBeInTheDocument();
      expect(container.querySelector('[data-ouia-component-id="pagination-bottom"]'))
        .toBeInTheDocument();
    });
    initial.done();
    multiplePages.done();
  },
);
