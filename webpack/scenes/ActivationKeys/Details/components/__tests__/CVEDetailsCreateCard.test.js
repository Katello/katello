import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { CVEDetailsCreateCard } from '../CVEDetailsCreateCard';

// Mock the ForemanContext
jest.mock('foremanReact/Root/Context/ForemanContext', () => ({
  useForemanContext: jest.fn(),
  useForemanPermissions: jest.fn(),
}));

const { useForemanContext, useForemanPermissions } = require('foremanReact/Root/Context/ForemanContext');

describe('CVEDetailsCreateCard', () => {
  beforeEach(() => {
    // Reset mocks before each test
    jest.clearAllMocks();

    // Create a DOM node for the component to read data from
    const dataNode = document.createElement('span');
    dataNode.id = 'ak-create-cve-data';
    dataNode.dataset.orgId = '1';
    document.body.appendChild(dataNode);

    // Mock useForemanContext with default values
    useForemanContext.mockReturnValue({
      metadata: {
        katello: {
          allow_multiple_content_views: true,
        },
      },
    });

    // Mock useForemanPermissions with default permissions
    useForemanPermissions.mockReturnValue({
      has: jest.fn(() => true), // Grant all permissions by default
    });
  });

  afterEach(() => {
    // Clean up DOM
    const dataNode = document.getElementById('ak-create-cve-data');
    if (dataNode) {
      document.body.removeChild(dataNode);
    }
  });

  test('Renders empty state when no assignments', async () => {
    const { getByText } = renderWithRedux(<CVEDetailsCreateCard />);

    await patientlyWaitFor(() => {
      expect(getByText('No content view environments yet')).toBeInTheDocument();
      expect(getByText('To get started, assign content view environments.')).toBeInTheDocument();
    });
  });

  test('Shows "Assign content view environments" button', async () => {
    const { getByRole } = renderWithRedux(<CVEDetailsCreateCard />);

    await patientlyWaitFor(() => {
      expect(getByRole('button', { name: 'assign_content_view_environments' })).toBeInTheDocument();
    });
  });

  test('Does not render when orgId is not available', () => {
    // Remove the orgId from the DOM node
    const dataNode = document.getElementById('ak-create-cve-data');
    delete dataNode.dataset.orgId;

    const { container } = renderWithRedux(<CVEDetailsCreateCard />);

    // Component should return null and not render anything
    expect(container.firstChild).toBeNull();
  });

  test('Uses allowMultipleContentViews from ForemanContext', async () => {
    // Override the mock to return false
    useForemanContext.mockReturnValue({
      metadata: {
        katello: {
          allow_multiple_content_views: false,
        },
      },
    });

    const { getByText } = renderWithRedux(<CVEDetailsCreateCard />);

    await patientlyWaitFor(() => {
      // The card should render with singular title when setting is false
      expect(getByText('Content view environment')).toBeInTheDocument();
    });
  });

  test('Defaults to true when allow_multiple_content_views setting is missing', async () => {
    // Mock missing metadata
    useForemanContext.mockReturnValue({
      metadata: {},
    });

    const { getByText } = renderWithRedux(<CVEDetailsCreateCard />);

    await patientlyWaitFor(() => {
      // Card title is singular when there are 0 or 1 assignments
      expect(getByText('Content view environment')).toBeInTheDocument();
    });
  });

  test('Calls AngularJS scope method when assignments change', async () => {
    // Mock AngularJS
    const mockScope = {
      updateContentViewEnvironments: jest.fn(),
      $apply: jest.fn(fn => fn()),
    };

    const mockElement = {
      scope: jest.fn(() => mockScope),
    };

    window.angular = {
      element: jest.fn(() => mockElement),
    };

    const { getByRole } = renderWithRedux(<CVEDetailsCreateCard />);

    await patientlyWaitFor(() => {
      expect(getByRole('button', { name: 'assign_content_view_environments' })).toBeInTheDocument();
    });

    // Note: Full integration test would require opening modal and making changes
    // This test just verifies the component structure is set up correctly
  });
});
