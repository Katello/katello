import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';

import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';

import RelatedContentViewComponentsModal from '../RelatedContentViewComponentsModal';
import RelatedCompositeContentViewsModal from '../RelatedCompositeContentViewsModal';

import contentViewComponentsResponse from './contentViewComponentsResponse.fixtures.json';

test('Can call API and show Related Content Views Components Modal', async (done) => {
  const cvId = 5;
  const relatedCvCount = 2;
  const cvName = 'italiano';
  const contentViewComponentsPath = api.getApiUrl(`/content_views/${cvId}/content_view_components/show_all`);
  const autocompleteUrl = '/content_views/auto_complete_search';
  const autocompleteQuery = {
    organization_id: 1,
    search: '',
  };
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);

  const scope = nockInstance
    .get(contentViewComponentsPath)
    .query(true)
    .reply(200, contentViewComponentsResponse);

  const { getByText, getByLabelText } = renderWithRedux(<RelatedContentViewComponentsModal
    cvId={cvId}
    cvName={cvName}
    relatedCVCount={relatedCvCount}
  />);

  await patientlyWaitFor(() => expect(getByLabelText(`button_${cvId}`)).toBeInTheDocument());
  fireEvent.click(getByLabelText(`button_${cvId}`));
  await patientlyWaitFor(() => expect(getByText('Related content views')).toBeInTheDocument());

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Can call API and show Related Composite Content Views Modal', async () => {
  const relatedCompositeCVs = [
    {
      id: 5,
      name: 'italiano',
    },
  ];

  const cvId = 3;
  const relatedCvCount = 1;
  const cvName = 'ravioli';

  const { getByText, getByLabelText } = renderWithRedux(<RelatedCompositeContentViewsModal
    cvId={cvId}
    cvName={cvName}
    relatedCVCount={relatedCvCount}
    relatedCompositeCVs={relatedCompositeCVs}
  />);
  await patientlyWaitFor(() => expect(getByLabelText(`button_${cvId}`)).toBeInTheDocument());
  fireEvent.click(getByLabelText(`button_${cvId}`));
  await patientlyWaitFor(() => expect(getByText('Related composite content views')).toBeInTheDocument());
});
