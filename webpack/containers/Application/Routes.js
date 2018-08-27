import React from 'react';
import { Route } from 'react-router-dom';
import { links } from './config';
import Header from './Headers';

export default () => (
  <div>
    {links.map(({ path, component, text }) => {
      const Page = component;
      const withHeader = () => (
        <React.Fragment>
          <Header title={text} />
          <Page />
        </React.Fragment>
      );

      return (
        <Route exact key={path} path={`/${path}`} component={withHeader} />
      );
    })}
  </div>
);
