import React from 'react';
import { Route } from 'react-router-dom';
import { links } from './config';

export default ({ org }) => (
  <div>
    {links.map(({ path, Component }) => (
      <Route exact key={path} path={`/${path}`} render={() => <Component org={org} />} />
      ))}
  </div>
);
