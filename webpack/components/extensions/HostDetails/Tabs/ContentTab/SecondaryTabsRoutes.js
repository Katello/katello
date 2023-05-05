import React from 'react';
import { Route, Switch, Redirect } from 'react-router-dom';
import { PackagesTab } from '../PackagesTab/PackagesTab.js';
import { ErrataTab } from '../ErrataTab/ErrataTab.js';
import { ModuleStreamsTab } from '../ModuleStreamsTab/ModuleStreamsTab';
import RepositorySetsTab from '../RepositorySetsTab/RepositorySetsTab';
import { route } from './helpers';

const SecondaryTabRoutes = () => (
  <Switch ouiaId="secondary-tab-routes-switch">
    <Route path={route('packages')}>
      <PackagesTab />
    </Route>
    <Route path={route('errata')}>
      <ErrataTab />
    </Route>
    <Route path={route('module-streams')}>
      <ModuleStreamsTab />
    </Route>
    <Route path={route('Repository sets')}>
      <RepositorySetsTab />
    </Route>
    <Redirect to={route('errata')} />
  </Switch>
);

export default SecondaryTabRoutes;
