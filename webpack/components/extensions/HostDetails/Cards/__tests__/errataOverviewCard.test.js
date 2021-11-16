import React from 'react';
import { render } from 'react-testing-lib-wrapper';
import ErrataOverviewCard from '../ErrataOverviewCard';
import nock from '../../../../../test-utils/nockWrapper';

describe('Without errata', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  test('does not show piechart when there are 0 errata', () => {
    const hostDetails = {
      id: 2,
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
});

describe('With errata', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  test('show piechart when there are errata', () => {
    const hostDetails = {
      id: 2,
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
