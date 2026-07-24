import React from 'react';
import PropTypes from 'prop-types';
import userEvent from '@testing-library/user-event';
import { screen } from '@testing-library/react';
import { rtlHelpers } from 'foremanReact/common/rtlTestHelpers';
import { patientlyWaitFor } from 'react-testing-lib-wrapper';
import api from '../../../../../services/api';
import { nockInstance, assertNockRequest } from '../../../../../test-utils/nockWrapper';
import {
  requestSuccessResponse,
  taskSuccessResponse,
} from '../../__tests__/upstreamSubscriptions.fixtures';
import useSaveUpstreamSubscriptions from '../useSaveUpstreamSubscriptions';

const { renderWithStore } = rtlHelpers;

const upstreamSubscriptionsPath = api.getApiUrl('/organizations/1/upstream_subscriptions');

const SaveTestComponent = ({ selectedRows, history }) => {
  const { saveUpstreamSubscriptions } = useSaveUpstreamSubscriptions({ selectedRows, history });

  return (
    <button type="button" onClick={saveUpstreamSubscriptions}>
      Save upstream subscriptions
    </button>
  );
};

SaveTestComponent.propTypes = {
  selectedRows: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  history: PropTypes.shape({ push: PropTypes.func.isRequired }).isRequired,
};

describe('useSaveUpstreamSubscriptions', () => {
  const selectedRows = [
    {
      id: requestSuccessResponse.results[0].id,
      updatedQuantity: '5',
    },
    {
      id: requestSuccessResponse.results[1].id,
      updatedQuantity: '10',
    },
  ];

  beforeEach(() => {
    window.tfm = {
      toastNotifications: {
        notify: jest.fn(),
      },
    };
  });

  it('posts all selected pool quantities in the request body', async () => {
    const history = { push: jest.fn() };
    let postedBody;

    const postScope = nockInstance
      .post(upstreamSubscriptionsPath, (body) => {
        postedBody = body;
        return true;
      })
      .reply(200, taskSuccessResponse);

    renderWithStore(<SaveTestComponent selectedRows={selectedRows} history={history} />);

    await userEvent.click(screen.getByRole('button', { name: 'Save upstream subscriptions' }));

    await patientlyWaitFor(() => {
      expect(postedBody).toEqual({
        pools: [
          { id: selectedRows[0].id, quantity: 5 },
          { id: selectedRows[1].id, quantity: 10 },
        ],
      });
    });

    assertNockRequest(postScope);
  });
});
