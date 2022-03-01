import React from 'react';
import { render } from 'react-testing-lib-wrapper';
import ContentViewDetailsCard from '../ContentViewDetailsCard';

test('shows host details when content facet is set', () => {
  const hostDetails = {
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
  };
  const { getByText } = render(<ContentViewDetailsCard hostDetails={hostDetails} />);
  expect(getByText('Version 1.0 (latest)')).toBeInTheDocument();
});


test('does not show host details when content facet is not set', () => {
  const { queryByText } = render(<ContentViewDetailsCard />);
  expect(queryByText('Version 1.0')).toBeNull();
});


test('shows host details not latest', () => {
  const hostDetails = {
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
      content_view_version_latest: false,
    },
  };
  const { getByText, queryByText } = render(<ContentViewDetailsCard hostDetails={hostDetails} />);
  expect(getByText('Version 1.0')).toBeInTheDocument();
  expect(queryByText('Version 1.0 (latest)')).toBeNull();
});
