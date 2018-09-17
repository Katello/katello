import React from 'react';
import { Route } from 'react-router-dom';
import { links } from './config';

export default () => (
  <div>
    {links.map(({ path, component }) => (
      <Route exact key={path} path={`/${path}`} component={component} />
      ))}
  </div>
);
