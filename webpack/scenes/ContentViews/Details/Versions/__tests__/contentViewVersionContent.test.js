import React from 'react';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import ContentViewVersionContent from '../ContentViewVersionContent';

const renderContent = cvVersion =>
  renderWithRedux(<ContentViewVersionContent
    cvId={3}
    versionId={73}
    cvVersion={cvVersion}
  />);

test('Shows no content when version has no counts', () => {
  const { getByText } = renderContent({});

  expect(getByText('No content')).toBeInTheDocument();
});

test('Shows module streams once from the generic content config', () => {
  const { getByText, getAllByText } = renderContent({ modulemd_count: 14 });

  expect(getAllByText('14 Module streams')).toHaveLength(1);
  expect(getByText('14 Module streams').closest('a'))
    .toHaveAttribute('href', expect.stringContaining('moduleStreams'));
});

test('Does not duplicate module streams when both count keys are present', () => {
  const { getAllByText, queryByText } = renderContent({
    modulemd_count: 14,
    module_stream_count: 14,
  });

  expect(getAllByText('14 Module streams')).toHaveLength(1);
  expect(queryByText('No content')).not.toBeInTheDocument();
});

test('Does not show module streams from the legacy count key alone', () => {
  const { getByText, queryByText } = renderContent({ module_stream_count: 14 });

  expect(queryByText(/Module streams/i)).not.toBeInTheDocument();
  expect(getByText('No content')).toBeInTheDocument();
});
