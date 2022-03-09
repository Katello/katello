import React from 'react';
import { render } from 'react-testing-lib-wrapper';
import ErrataOverviewCard from '../ErrataOverviewCard';
import nock from '../../../../../test-utils/nockWrapper';

const baseHostDetails = {
  id: 2,
  subscription_facet_attributes: {
    uuid: '123',
  },
};

describe('Without errata', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  test('does not show piechart when there are 0 errata', () => {
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
    };
    /* eslint-disable max-len */
    const { queryByLabelText, getByText } = render(<ErrataOverviewCard hostDetails={hostDetails} />);
    /* eslint-enable max-len */
    expect(queryByLabelText('errataChart')).not.toBeInTheDocument();
    expect(getByText('0 errata')).toBeInTheDocument();
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

  test('shows piechart when there are errata', () => {
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
    const { getByText, container } = render(<ErrataOverviewCard hostDetails={hostDetails} />);
    expect(container.getElementsByClassName('erratachart')).toHaveLength(1);
    expect(container.getElementsByClassName('erratalegend')).toHaveLength(1);
    expect(getByText('60 errata')).toBeInTheDocument();
    expect(getByText('30 security advisories')).toBeInTheDocument();
    expect(getByText('10 bug fixes')).toBeInTheDocument();
    expect(getByText('20 enhancements')).toBeInTheDocument();
  });
});
