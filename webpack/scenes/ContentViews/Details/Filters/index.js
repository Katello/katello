import React from 'react';
import { Route } from 'react-router-dom';
import { number } from 'prop-types';
import ContentViewFilters from './ContentViewFilters';
import ContentViewFilterDetails from './ContentViewFilterDetails';

const ContentViewFiltersRoutes = ({ cvId }) => (
  <>
    <Route exact path="/filters">
      <ContentViewFilters cvId={cvId} />
    </Route>
    <Route path="/filters/:filterId([0-9]+)">
      <ContentViewFilterDetails cvId={cvId} />
    </Route>
  </>
);


ContentViewFiltersRoutes.propTypes = {
  cvId: number.isRequired,
};

export default ContentViewFiltersRoutes;
