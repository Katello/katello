import React from 'react';
import { render, waitFor, fireEvent } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../test-utils/nockWrapper';

import Search from '../../Search';

const endpoint = '/fake_endpoint';
const props = {
  onSearch: jest.fn(),
  getAutoCompleteParams: search => ({
    params: { organization_id: 1, search },
    endpoint,
  }),
  patternfly4: true,
};

test('Autocomplete shows on input', async (done) => {
  const suggestion = 'suggestedQuery';
  const response = [
    {
      completed: '', part: ` ${suggestion} `, label: ` ${suggestion} `, category: '',
    },
  ];
  const query = { organization_id: 1, search: 'foo' };
  const initialScope = mockAutocomplete(nockInstance, endpoint, { ...query, search: '' }, []);
  const autocompleteScope = mockAutocomplete(nockInstance, endpoint, query, response);

  const { getByLabelText, getByText, queryByText } = render(<Search {...props} />);

  expect(queryByText(`${suggestion}`)).not.toBeInTheDocument();

  fireEvent.change(getByLabelText(/text input for search/i), { target: { value: 'foo' } });

  await waitFor(() => expect(getByText(`${suggestion}`)).toBeInTheDocument());

  assertNockRequest(initialScope);
  assertNockRequest(autocompleteScope, done);
});
