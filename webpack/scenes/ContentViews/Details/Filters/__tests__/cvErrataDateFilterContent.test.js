import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent, act } from 'react-testing-lib-wrapper';
import * as reactRedux from 'react-redux';
import {
  nockInstance,
  assertNockRequest,
} from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import CVErrataDateFilterContent from '../CVErrataDateFilterContent';
import cvFilterDetails from './contentViewErrataByDateDetails.fixtures.json';
import details from '../../../__tests__/mockDetails.fixtures.json';

const cvErrataDateRuleEditPath = api.getApiUrl('/content_view_filters/36/rules/35');

test('Can display errata-date filter rule and edit', async (done) => {
  const useSelectorMock = jest.spyOn(reactRedux, 'useSelector');
  useSelectorMock.mockReturnValue(cvFilterDetails);

  const editDetails = {
    id: 35,
    content_view_filter_id: '36',
    start_date: null,
    end_date: '2020-08-15T12:00:00.000Z',
    types: ['enhancement', 'security'],
    date_type: 'issued',
    allow_other_types: false,
  };

  const ruleEditScope = nockInstance
    .put(cvErrataDateRuleEditPath, editDetails)
    .reply(200, cvFilterDetails);

  const {
    getByText, queryByText, getByLabelText, getAllByText, queryAllByText,
  } = renderWithRedux(<CVErrataDateFilterContent
    cvId={1}
    filterId="36"
    showAffectedRepos={false}
    setShowAffectedRepos={() => { }}
    details={details}
  />);

  await patientlyWaitFor(() => {
    expect(getAllByText('ANY')).toHaveLength(2);
    expect(getByLabelText('save_filter_rule')).toHaveAttribute('aria-disabled', 'true');
  });
  fireEvent.change(getByLabelText('start_date_input'), { target: { value: '08/15/1990' } });
  fireEvent.change(getByLabelText('end_date_input'), { target: { value: '08/15/2020' } });
  await patientlyWaitFor(() => {
    expect(queryAllByText('ANY')).toHaveLength(0);
    expect(getByText('08/15/1990')).toBeInTheDocument();
    expect(getByText('08/15/2020')).toBeInTheDocument();
  });
  // Can clear date with chip
  await act(async () => {
    getByLabelText('08/15/1990').click();
  });
  await patientlyWaitFor(() => {
    expect(getByText('ANY')).toBeInTheDocument();
    expect(queryByText('08/15/1990')).not.toBeInTheDocument();
    expect(getByText('08/15/2020')).toBeInTheDocument();
    // Enabled Edit rule button
    expect(getByLabelText('save_filter_rule')).toHaveAttribute('aria-disabled', 'false');
  });
  await act(async () => {
    getByLabelText('save_filter_rule').click();
  });

  useSelectorMock.mockClear();
  assertNockRequest(ruleEditScope);
  done();
});
