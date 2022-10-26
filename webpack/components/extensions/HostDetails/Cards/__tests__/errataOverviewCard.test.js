import React from 'react';
import { renderWithRedux, fireEvent } from 'react-testing-lib-wrapper';
import ErrataOverviewCard from '../ErrataOverviewCard';

const baseHostDetails = {
  id: 2,
  subscription_facet_attributes: {
    uuid: '123',
  },
};
const baseFacetAttributes = {
  errata_status: 0, // all up to date
  content_facet_attributes: {
    errata_counts: {
      bugfix: 0,
      enhancement: 0,
      security: 0,
      total: 0,
      applicable: {
        bugfix: 0,
        enhancement: 0,
        security: 0,
        total: 0,
      },
    },
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
  test('shows zero counts when there are 0 installable errata', () => {
    const hostDetails = {
      ...baseHostDetails,
      ...baseFacetAttributes,
      errata_status: 2,
    };
    /* eslint-disable max-len */
    const { queryByLabelText, getByLabelText } = renderWithRedux(<ErrataOverviewCard hostDetails={hostDetails} />, renderOptions);
    /* eslint-enable max-len */
    expect(queryByLabelText('errataChart')).not.toBeInTheDocument();
    expect(getByLabelText('0 total errata')).toBeInTheDocument();
    expect(getByLabelText('0 security advisories')).toBeInTheDocument();
    expect(getByLabelText('0 bug fixes')).toBeInTheDocument();
    expect(getByLabelText('0 enhancements')).toBeInTheDocument();
  });

  test('shows happy empty state when there are 0 errata', () => {
    const hostDetails = {
      ...baseHostDetails,
      ...baseFacetAttributes,
    };
    /* eslint-disable max-len */
    const { queryByLabelText, getByText } = renderWithRedux(<ErrataOverviewCard hostDetails={hostDetails} />, renderOptions);
    /* eslint-enable max-len */
    expect(queryByLabelText('errataChart')).not.toBeInTheDocument();
    expect(getByText('All errata up-to-date')).toBeInTheDocument();
  });

  // test for showing warning empty state when it has unknown errata status
  test('shows warning empty state when it has unknown errata status', () => {
    const hostDetails = {
      ...baseHostDetails,
      ...baseFacetAttributes,
      errata_status: 1,
    };
    const { queryByLabelText, getByText }
      = renderWithRedux(<ErrataOverviewCard hostDetails={hostDetails} />, renderOptions);
    expect(queryByLabelText('errataChart')).not.toBeInTheDocument();
    expect(getByText('Unknown errata status')).toBeInTheDocument();
  });

  test('does not show errata card when host not registered', () => {
    const hostDetails = {
      ...baseHostDetails,
      ...baseFacetAttributes,
      subscription_facet_attributes: undefined,
    };
    /* eslint-disable max-len */
    const { queryByLabelText, queryByText } = renderWithRedux(<ErrataOverviewCard hostDetails={hostDetails} />, renderOptions);
    /* eslint-enable max-len */
    expect(queryByLabelText('errataChart')).not.toBeInTheDocument();
    expect(queryByText('No errata')).not.toBeInTheDocument();
  });
});

describe('With errata', () => {
  test('shows links when there are errata', () => {
    const hostDetails = {
      ...baseHostDetails,
      errata_status: 2,
      content_facet_attributes: {
        errata_counts: {
          bugfix: 10,
          enhancement: 20,
          security: 30,
          total: 60,
          applicable: {
            bugfix: 10,
            enhancement: 20,
            security: 30,
            total: 60,
          },
        },
      },
    };
    const { getByLabelText, container }
      = renderWithRedux(<ErrataOverviewCard hostDetails={hostDetails} />, renderOptions);
    expect(container.getElementsByClassName('erratachart')).toHaveLength(1);
    expect(container.getElementsByClassName('erratalegend')).toHaveLength(1);

    expect(getByLabelText('60 total errata')).toBeInTheDocument();
    expect(getByLabelText('30 security advisories')).toBeInTheDocument();
    expect(getByLabelText('20 enhancements')).toBeInTheDocument();
    expect(getByLabelText('10 bug fixes')).toBeInTheDocument();
  });

  test('Can toggle between applicable and installable with toggle group', () => {
    const hostDetails = {
      ...baseHostDetails,
      errata_status: 2,
      content_facet_attributes: {
        errata_counts: {
          bugfix: 10,
          enhancement: 20,
          security: 30,
          total: 60,
          applicable: {
            bugfix: 11,
            enhancement: 21,
            security: 31,
            total: 61,
          },
        },
      },
    };
    const { getByLabelText, container, getByText }
      = renderWithRedux(<ErrataOverviewCard hostDetails={hostDetails} />, renderOptions);
    expect(container.getElementsByClassName('erratachart')).toHaveLength(1);
    expect(container.getElementsByClassName('erratalegend')).toHaveLength(1);

    expect(getByText('Applicable').parentElement).toHaveAttribute('aria-pressed', 'true');

    expect(getByLabelText('61 total errata')).toBeInTheDocument();
    expect(getByLabelText('31 security advisories')).toBeInTheDocument();
    expect(getByLabelText('21 enhancements')).toBeInTheDocument();
    expect(getByLabelText('11 bug fixes')).toBeInTheDocument();

    fireEvent.click(getByText('Installable'));

    expect(getByLabelText('60 total errata')).toBeInTheDocument();
    expect(getByLabelText('30 security advisories')).toBeInTheDocument();
    expect(getByLabelText('20 enhancements')).toBeInTheDocument();
    expect(getByLabelText('10 bug fixes')).toBeInTheDocument();
  });
});
