import React from 'react';
import { Route, Switch, Redirect } from 'react-router-dom';
import { ErrataTab } from '../ErrataTab';
import EmptyPage from './EmptyPage';
import { route } from './helpers';

const SecondaryTabRoutes = () => (
  <Switch>
    <Route exact path="/Content">
      <Redirect to={route('packages')} />
    </Route>
    <Route path={route('packages')}>
      <EmptyPage header="WIP Packages" />
    </Route>
    <Route path={route('errata')}>
      <ErrataTab />
    </Route>
    <Route path={route('modulestreams')}>
      <EmptyPage header="WIP Module streams" />
    </Route>
  </Switch>
);

export default SecondaryTabRoutes;
