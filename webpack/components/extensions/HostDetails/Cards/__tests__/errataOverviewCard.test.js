import React from 'react';
import { render, renderWithRedux } from 'react-testing-lib-wrapper';
import ErrataOverviewCard from '../ErrataOverviewCard';
import nock from '../../../../../test-utils/nockWrapper';

const baseHostDetails = {
  id: 2,
  subscription_facet_attributes: {
    uuid: '123',
  },
};
const renderOptions = {
  initialState: {
    // This is the API state that your tests depend on for their data
    // You can cross reference the needed useSelectors from your tested components
    // with the data found within the redux chrome add-on to help determine this fixture data.
    katello: {
      hostDetails: {},
    },
  },
};
describe('Without errata', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  test('shows zero counts when there are 0 installable errata', () => {
    const hostDetails = {
      ...baseHostDetails,
      errata_status: 1,
      content_facet_attributes: {
        errata_counts: {
          bugfix: 0,
          enhancement: 0,
          security: 0,
          total: 0,
        },
      },
    };
    /* eslint-disable max-len */
    const { queryByLabelText, getByLabelText } = render(<ErrataOverviewCard hostDetails={hostDetails} />);
    /* eslint-enable max-len */
    expect(queryByLabelText('errataChart')).not.toBeInTheDocument();
    expect(getByLabelText('0 total errata')).toBeInTheDocument();
    expect(getByLabelText('0 security advisories')).toBeInTheDocument();
    expect(getByLabelText('0 bug fixes')).toBeInTheDocument();
    expect(getByLabelText('0 enhancements')).toBeInTheDocument();
  });

  test('shows empty state when there are 0 errata', () => {
    const hostDetails = {
      ...baseHostDetails,
      errata_status: 0,
      content_facet_attributes: {
        errata_counts: {
          bugfix: 0,
          enhancement: 0,
          security: 0,
          total: 0,
        },
      },
    };
    /* eslint-disable max-len */
    const { queryByLabelText, getByText } = renderWithRedux(<ErrataOverviewCard hostDetails={hostDetails} />, renderOptions);
    /* eslint-enable max-len */
    expect(queryByLabelText('errataChart')).not.toBeInTheDocument();
    expect(getByText('All errata up-to-date')).toBeInTheDocument();
  });

  test('does not show errata card when host not registered', () => {
    const hostDetails = {
      ...baseHostDetails,
      content_facet_attributes: {
        errata_counts: {
          bugfix: 0,
          enhancement: 0,
          security: 0,
          total: 0,
        },
      },
      subscription_facet_attributes: undefined,
    };
    /* eslint-disable max-len */
    const { queryByLabelText, queryByText } = render(<ErrataOverviewCard hostDetails={hostDetails} />);
    /* eslint-enable max-len */
    expect(queryByLabelText('errataChart')).not.toBeInTheDocument();
    expect(queryByText('0 errata')).not.toBeInTheDocument();
  });
});

describe('With errata', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  test('shows links when there are errata', () => {
    const hostDetails = {
      ...baseHostDetails,
      content_facet_attributes: {
        errata_counts: {
          bugfix: 10,
          enhancement: 20,
          security: 30,
          total: 60,
        },
      },
    };
    const { getByLabelText, container } = render(<ErrataOverviewCard hostDetails={hostDetails} />);
    expect(container.getElementsByClassName('erratachart')).toHaveLength(1);
    expect(container.getElementsByClassName('erratalegend')).toHaveLength(1);

    expect(getByLabelText('60 total errata')).toBeInTheDocument();
    expect(getByLabelText('30 security advisories')).toBeInTheDocument();
    expect(getByLabelText('20 enhancements')).toBeInTheDocument();
    expect(getByLabelText('10 bug fixes')).toBeInTheDocument();
  });
});
