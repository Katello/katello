import React from 'react';
import { Route, Switch, Redirect } from 'react-router-dom';
import { PackagesTab } from '../PackagesTab/PackagesTab.js';
import { ErrataTab } from '../ErrataTab/ErrataTab.js';
import { ModuleStreamsTab } from '../ModuleStreamsTab/ModuleStreamsTab';
import { route } from './helpers';

const SecondaryTabRoutes = () => (
  <Switch>
    <Route path={route('packages')}>
      <PackagesTab />
    </Route>
    <Route path={route('errata')}>
      <ErrataTab />
    </Route>
    <Route path={route('module-streams')}>
      <ModuleStreamsTab />
    </Route>
    <Redirect to={route('errata')} />
  </Switch>
);

export default SecondaryTabRoutes;
