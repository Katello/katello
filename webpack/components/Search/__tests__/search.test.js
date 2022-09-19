import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import {
  nockInstance, assertNockRequest, mockAutocomplete, mockSetting,
} from '../../../test-utils/nockWrapper';
import { AUTOSEARCH_WHILE_TYPING, AUTOSEARCH_DELAY } from '../../../scenes/Settings/SettingsConstants.js';
import Search from '../../Search';

const endpoint = '/fake_endpoint';
const searchButtonLabel = 'search button';
const props = {
  onSearch: jest.fn(),
  getAutoCompleteParams: search => ({
    params: { organization_id: 1, search },
    endpoint,
  }),
  patternfly4: true,
};

let searchDelayScope;
beforeEach(() => {
  searchDelayScope = mockSetting(nockInstance, AUTOSEARCH_DELAY, 0);
});

afterEach(() => {
  assertNockRequest(searchDelayScope);
});

jest.mock('../../../utils/useDebounce', () => ({
  __esModule: true,
  default: value => value,
}));


test('Autocomplete shows on input', async (done) => {
  const suggestion = 'suggestedQuery';
  const response = [
    {
      completed: '', part: ` ${suggestion} `, label: ` ${suggestion} `, category: '',
    },
  ];
  const query = { organization_id: 1, search: 'foo' };
  const autoSearchScope = mockSetting(nockInstance, AUTOSEARCH_WHILE_TYPING, true);
  const initialScope = mockAutocomplete(nockInstance, endpoint, { ...query, search: '' }, []);
  const autocompleteScope = mockAutocomplete(nockInstance, endpoint, query, response);

  const { getByLabelText, getByText, queryByText } = renderWithRedux(<Search {...props} />);

  expect(queryByText(`${suggestion}`)).not.toBeInTheDocument();

  fireEvent.change(getByLabelText(/text input for search/i), { target: { value: 'foo' } });

  await patientlyWaitFor(() => expect(getByText(`${suggestion}`)).toBeInTheDocument());

  assertNockRequest(initialScope);
  assertNockRequest(autoSearchScope);
  assertNockRequest(autocompleteScope, done);
});

test('autosearch turned off does show patternfly 4 search button', async (done) => {
  const autoSearchScope = mockSetting(nockInstance, AUTOSEARCH_WHILE_TYPING, false);
  const autocompleteScope = mockAutocomplete(nockInstance, endpoint);

  const { getByLabelText } = renderWithRedux(<Search {...props} />);

  // Using patientlyWaitFor as the autoSearch setting defaults to true,
  // it won't be changed until http call
  await patientlyWaitFor(() => expect(getByLabelText(searchButtonLabel)).toBeInTheDocument());

  assertNockRequest(autoSearchScope);
  assertNockRequest(autocompleteScope, done);
});

test('search function is called when search is typed into with autosearch', async (done) => {
  const autoSearchScope = mockSetting(nockInstance, AUTOSEARCH_WHILE_TYPING);
  const autocompleteScope = mockAutocomplete(nockInstance, endpoint, true, [], 2);
  const mockSearch = jest.fn();

  const { getByLabelText } = renderWithRedux(<Search {...{ ...props, onSearch: mockSearch }} />);
  fireEvent.change(getByLabelText(/text input for search/i), { target: { value: 'name = foo' } });
  await patientlyWaitFor(() => expect(mockSearch.mock.calls).toHaveLength(1));

  assertNockRequest(autoSearchScope);
  assertNockRequest(autocompleteScope, done);
});

test('search function is called by clicking search button without autosearch', async (done) => {
  const autoSearchScope = mockSetting(nockInstance, AUTOSEARCH_WHILE_TYPING, false);
  const autocompleteScope = mockAutocomplete(nockInstance, endpoint, true, [], 2);
  const mockSearch = jest.fn();

  const { getByLabelText } = renderWithRedux(<Search {...{ ...props, onSearch: mockSearch }} />);

  fireEvent.change(getByLabelText(/text input for search/i), { target: { value: 'foo' } });
  let searchButton;
  await patientlyWaitFor(() => {
    searchButton = getByLabelText(searchButtonLabel);
    expect(searchButton).toBeInTheDocument();
  });
  searchButton.click();
  expect(mockSearch.mock.calls).toHaveLength(1);
  assertNockRequest(autoSearchScope);
  assertNockRequest(autocompleteScope, done);
});
