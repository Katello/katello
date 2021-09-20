import React from 'react';
import { Route } from 'react-router-dom';
import ContentViewVersions from './ContentViewVersions';
import ContentViewVersionDetails from './VersionDetails/ContentViewVersionDetails';

export default () => (
  <>
    <Route exact path="/labs/content_views/:id([0-9]+)/versions" component={ContentViewVersions} />
    <Route path="/labs/content_views/:id([0-9]+)/versions/:versionId([0-9]+)" component={ContentViewVersionDetails} />
  </>
);

