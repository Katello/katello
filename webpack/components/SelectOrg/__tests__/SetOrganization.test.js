import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { fireEvent } from '@testing-library/react';
import { nockInstance, assertNockRequest } from '../../../test-utils/nockWrapper';
import { foremanApi } from '../../../services/api';
import SetOrganization from '../SetOrganization';

const organizationsPath = foremanApi.getApiUrl('/organizations');

const mockOrganizations = {
  total: 3,
  subtotal: 3,
  page: 1,
  per_page: 20,
  results: [
    { id: 1, name: 'Default Organization' },
    { id: 2, name: 'Dev Org' },
    { id: 3, name: 'Test Org' },
  ],
};

describe('SetOrganization', () => {
  beforeEach(() => {
    delete window.location;
    window.location = { href: '' };
  });

  test('renders organization selector after loading', async () => {
    const scope = nockInstance
      .get(organizationsPath)
      .query(true)
      .reply(200, mockOrganizations);

    const { getByText, getByLabelText } = renderWithRedux(<SetOrganization />);

    await patientlyWaitFor(() => {
      expect(getByText('Select an Organization')).toBeInTheDocument();
      expect(getByText('The page you are attempting to access requires selecting a specific organization.')).toBeInTheDocument();
    });

    const select = getByLabelText('Select an organization');
    expect(select).toBeInTheDocument();
    expect(select.options).toHaveLength(4); // placeholder + 3 orgs

    assertNockRequest(scope);
  });

  test('Select button is initially disabled', async () => {
    const scope = nockInstance
      .get(organizationsPath)
      .query(true)
      .reply(200, mockOrganizations);

    const { getByText } = renderWithRedux(<SetOrganization />);

    await patientlyWaitFor(() => {
      const button = getByText('Select');
      expect(button).toBeInTheDocument();
      expect(button).toBeDisabled();
    });

    assertNockRequest(scope);
  });

  test('Select button becomes enabled after choosing an organization', async () => {
    const scope = nockInstance
      .get(organizationsPath)
      .query(true)
      .reply(200, mockOrganizations);

    const { getByText, getByLabelText } = renderWithRedux(<SetOrganization />);

    await patientlyWaitFor(() => {
      expect(getByText('Select an Organization')).toBeInTheDocument();
    });

    const select = getByLabelText('Select an organization');
    fireEvent.change(select, { target: { value: '2' } });

    await patientlyWaitFor(() => {
      const button = getByText('Select');
      expect(button).not.toBeDisabled();
    });

    assertNockRequest(scope);
  });

  test('clicking Select button navigates to correct URL', async () => {
    const scope = nockInstance
      .get(organizationsPath)
      .query(true)
      .reply(200, mockOrganizations);

    const { getByText, getByLabelText } = renderWithRedux(<SetOrganization />);

    await patientlyWaitFor(() => {
      expect(getByText('Select an Organization')).toBeInTheDocument();
    });

    const select = getByLabelText('Select an organization');
    fireEvent.change(select, { target: { value: '2' } });

    const button = getByText('Select');
    fireEvent.click(button);

    expect(window.location.href).toBe('/organizations/2/select');

    assertNockRequest(scope);
  });

  test('displays all organizations in the dropdown', async () => {
    const scope = nockInstance
      .get(organizationsPath)
      .query(true)
      .reply(200, mockOrganizations);

    const { getByText, getByLabelText } = renderWithRedux(<SetOrganization />);

    await patientlyWaitFor(() => {
      expect(getByText('Select an Organization')).toBeInTheDocument();
    });

    const select = getByLabelText('Select an organization');
    expect(select.options).toHaveLength(4); // placeholder + 3 orgs
    expect(select.options[1].text).toBe('Default Organization');
    expect(select.options[2].text).toBe('Dev Org');
    expect(select.options[3].text).toBe('Test Org');

    assertNockRequest(scope);
  });
});
