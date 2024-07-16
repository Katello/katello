import React from 'react';
import { render } from 'react-testing-lib-wrapper';
import ContentViewDetailsCard from '../ContentViewDetailsCard';

const baseHostDetails = {
  organization_id: 1,
  content_facet_attributes: {
    content_view: {
      name: 'CV',
      id: 100,
      composite: false,
      content_view_default: false,
    },
    lifecycle_environment: {
      name: 'ENV',
      id: 300,
    },
    content_view_version_id: 1000,
    content_view_version: '1.0',
    content_view_version_latest: true,
    content_view_environments: [
      {
        content_view: {
          name: 'CV',
          id: 100,
          composite: false,
          content_view_default: false,
          content_view_version_id: 1000,
          content_view_version: '1.0',
          content_view_version_latest: true,
        },
        lifecycle_environment: {
          name: 'ENV',
          id: 300,
        },
      },
    ],
  },
  subscription_facet_attributes: {
    uuid: '123',
  },
};

test('shows content view details when host is registered', () => {
  const { getByText } = render(<ContentViewDetailsCard hostDetails={baseHostDetails} />);
  expect(getByText('Version {version} (latest)')).toBeInTheDocument();
});


test('does not show content view details when host is not registered', () => {
  const hostDetails = {
    ...baseHostDetails,
    subscription_facet_attributes: undefined,
  };
  const { queryByText } = render(<ContentViewDetailsCard hostDetails={hostDetails} />);
  expect(queryByText('Version {version}')).toBeNull();
});


test('shows when the CV in use is not the latest version', () => {
  const hostDetails = {
    ...baseHostDetails,
    content_facet_attributes: {
      ...baseHostDetails.content_facet_attributes,
      content_view_environments: [
        {
          content_view: {
            ...baseHostDetails.content_facet_attributes.content_view_environments[0].content_view,
            content_view_version_latest: false,
          },
          lifecycle_environment: baseHostDetails.content_facet_attributes.lifecycle_environment,
        },
      ],
    },
  };
  const { getByText, queryByText } = render(<ContentViewDetailsCard hostDetails={hostDetails} />);
  expect(getByText('Version {version}')).toBeInTheDocument();
  expect(queryByText('Version {version} (latest)')).toBeNull();
});

test('does not show version info when using Default Organization View', () => {
  const hostDetails = {
    ...baseHostDetails,
    content_facet_attributes: {
      ...baseHostDetails.content_facet_attributes,
      content_view_environments: [
        {
          content_view: {
            ...baseHostDetails.content_facet_attributes.content_view_environments[0].content_view,
            content_view_default: true,
            name: 'Default Organization View',
          },
          lifecycle_environment: baseHostDetails.content_facet_attributes.lifecycle_environment,
        },
      ],
    },
  };

  const { queryByText } = render(<ContentViewDetailsCard hostDetails={hostDetails} />);
  expect(queryByText('Default Organization View')).toBeInTheDocument();
  expect(queryByText('Version {version}')).toBeNull();
});

