import React from 'react';
import { Route, Switch, Redirect } from 'react-router-dom';
import { PackagesTab } from '../PackagesTab';
import { ErrataTab } from '../ErrataTab/ErrataTab.js';
import { route } from './helpers';

const SecondaryTabRoutes = () => (
  <Switch>
    <Route exact path="/Content">
      <Redirect to={route('errata')} />
    </Route>
    <Route path={route('packages')}>
      <PackagesTab />
    </Route>
    <Route path={route('errata')}>
      <ErrataTab />
    </Route>
  </Switch>
);

export default SecondaryTabRoutes;
