import React from 'react';
import { Route } from 'react-router-dom';
import { number } from 'prop-types';
import ContentViewVersions from './ContentViewVersions';
import ContentViewVersionDetails from './VersionDetails/ContentViewVersionDetails';

const ContentViewVersionsRoutes = ({ cvId }) => (
  <>
    <Route exact path="/versions">
      <ContentViewVersions cvId={cvId} />
    </Route>
    <Route path="/versions/:versionId([0-9]+)">
      <ContentViewVersionDetails cvId={cvId} />
    </Route>
  </>
);

ContentViewVersionsRoutes.propTypes = {
  cvId: number.isRequired,
};

export default ContentViewVersionsRoutes;
