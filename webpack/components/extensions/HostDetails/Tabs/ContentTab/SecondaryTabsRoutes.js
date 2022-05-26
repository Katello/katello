import React from 'react';
import { Route, Switch, Redirect, useLocation } from 'react-router-dom';
import { PackagesTab } from '../PackagesTab/PackagesTab.js';
import { ErrataTab } from '../ErrataTab/ErrataTab.js';
import { ModuleStreamsTab } from '../ModuleStreamsTab/ModuleStreamsTab';
import  RepositorySetsTab  from '../RepositorySetsTab/RepositorySetsTab';
import { route } from './helpers';

const SecondaryTabRoutes = () => {
  console.log(route('Repository%20sets'));
  console.log(useLocation());
  return (
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

      <Route path={route('Repository sets')}>

        <RepositorySetsTab />
      </Route>

      <Redirect to={route('errata')} />

    </Switch>
  );
};

export default SecondaryTabRoutes;
