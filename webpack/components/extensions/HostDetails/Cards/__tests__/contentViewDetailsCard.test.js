import React from 'react';
import { render } from 'react-testing-lib-wrapper';
import ContentViewDetailsCard from '../ContentViewDetailsCard';

const baseHostDetails = {
  content_facet_attributes: {
    content_view: {
      name: 'CV',
      id: 100,
      composite: false,
    },
    lifecycle_environment: {
      name: 'ENV',
      id: 300,
    },
    content_view_version_id: 1000,
    content_view_version: '1.0',
    content_view_version_latest: true,
  },
  subscription_facet_attributes: {
    uuid: '123',
  },
};

test('shows content view details when host is registered', () => {
  const { getByText } = render(<ContentViewDetailsCard hostDetails={baseHostDetails} />);
  expect(getByText('Version 1.0 (latest)')).toBeInTheDocument();
});


test('does not show content view details when host is not registered', () => {
  const hostDetails = {
    ...baseHostDetails,
    subscription_facet_attributes: undefined,
  };
  const { queryByText } = render(<ContentViewDetailsCard hostDetails={hostDetails} />);
  expect(queryByText('Version 1.0')).toBeNull();
});


test('shows when the CV in use is not the latest version', () => {
  const hostDetails = {
    ...baseHostDetails,
    content_facet_attributes: {
      ...baseHostDetails.content_facet_attributes,
      content_view_version_latest: false,
    },
  };
  const { getByText, queryByText } = render(<ContentViewDetailsCard hostDetails={hostDetails} />);
  expect(getByText('Version 1.0')).toBeInTheDocument();
  expect(queryByText('Version 1.0 (latest)')).toBeNull();
});
