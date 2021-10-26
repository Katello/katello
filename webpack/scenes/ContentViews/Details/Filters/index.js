import React from 'react';
import { Route } from 'react-router-dom';
import { number, shape } from 'prop-types';
import ContentViewFilters from './ContentViewFilters';
import ContentViewFilterDetails from './ContentViewFilterDetails';

const ContentViewFiltersRoutes = ({ cvId, details }) => (
  <>
    <Route exact path="/filters">
      <ContentViewFilters cvId={cvId} details={details} />
    </Route>
    <Route path="/filters/:filterId([0-9]+)">
      <ContentViewFilterDetails cvId={cvId} details={details} />
    </Route>
  </>
);


ContentViewFiltersRoutes.propTypes = {
  cvId: number.isRequired,
  details: shape({
    permissions: shape({}),
  }).isRequired,
};

export default ContentViewFiltersRoutes;
