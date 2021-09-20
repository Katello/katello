import React from 'react';
import { Route } from 'react-router-dom';
import ContentViewFilters from './ContentViewFilters';
import ContentViewFilterDetails from './ContentViewFilterDetails';

export default () => (
  <>
    <Route exact path="/labs/content_views/:id([0-9]+)/filters" component={ContentViewFilters} />
    <Route path="/labs/content_views/:id([0-9]+)/filters/:filterId([0-9]+)" component={ContentViewFilterDetails} />
  </>
);

