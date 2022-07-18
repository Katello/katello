import React from 'react';
import { Route } from 'react-router-dom';
import { number, shape } from 'prop-types';
import ContentViewVersions from './ContentViewVersions';
import ContentViewVersionDetails from './VersionDetails/ContentViewVersionDetails';

const ContentViewVersionsRoutes = ({ cvId, details }) => (
  <>
    <Route exact path="/versions">
      <ContentViewVersions cvId={cvId} details={details} />
    </Route>
    <Route path="/versions/:versionId([0-9]+)">
      <ContentViewVersionDetails cvId={cvId} details={details} />
    </Route>
  </>
);

ContentViewVersionsRoutes.propTypes = {
  cvId: number.isRequired,
  details: shape({
    permissions: shape({}),
  }).isRequired,
};

export default ContentViewVersionsRoutes;
