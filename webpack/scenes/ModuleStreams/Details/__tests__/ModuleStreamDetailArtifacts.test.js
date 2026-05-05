import React from 'react';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import * as ContentSelectors from '../../../Content/ContentSelectors';
import * as ContentActions from '../../../Content/ContentActions';
import ModuleStreamDetailArtifacts from '../ModuleStreamDetailArtifacts';
import { details } from './moduleStreamDetails.fixtures';

jest.mock('../../../Content/ContentSelectors');
jest.mock('../../../Content/ContentActions');

describe('Module stream detail artifacts component', () => {
  const contentType = 'modulemd';
  const id = 22;

  beforeEach(() => {
    ContentSelectors.selectContentDetails.mockReturnValue(details);
    ContentSelectors.selectContentDetailsStatus.mockReturnValue('RESOLVED');
    ContentActions.getContentDetails.mockReturnValue({ type: 'GET_CONTENT_DETAILS' });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  test('renders artifact list with all artifact names', () => {
    const component = <ModuleStreamDetailArtifacts contentType={contentType} id={id} />;
    const { getByText } = renderWithRedux(component);

    const firstArtifact = 'python3-avocado-plugins-varianter-yaml-to-mux-0:63.0-2.module_2037+1b0ad681.noarch';
    const secondArtifact = 'python3-avocado-plugins-varianter-pict-0:63.0-2.module_2037+1b0ad681.noarch';

    expect(getByText(firstArtifact)).toBeInTheDocument();
    expect(getByText(secondArtifact)).toBeInTheDocument();
  });

  test('renders each artifact in a list item', () => {
    const component = <ModuleStreamDetailArtifacts contentType={contentType} id={id} />;
    const { getAllByRole } = renderWithRedux(component);

    const listItems = getAllByRole('listitem');
    expect(listItems).toHaveLength(details.artifacts.length);
  });

  test('renders empty state when no artifacts', () => {
    ContentSelectors.selectContentDetails.mockReturnValue({ artifacts: [] });

    const component = <ModuleStreamDetailArtifacts contentType={contentType} id={id} />;
    const { getByText } = renderWithRedux(component);

    expect(getByText('No artifacts to show')).toBeInTheDocument();
  });

  test('renders loading state when pending', () => {
    ContentSelectors.selectContentDetailsStatus.mockReturnValue('PENDING');

    const component = <ModuleStreamDetailArtifacts contentType={contentType} id={id} />;
    const { getByText } = renderWithRedux(component);

    // Should show loading text
    expect(getByText('Loading')).toBeInTheDocument();
  });
});
