import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
import reducer from '../../scenes/Organizations/OrganizationReducer';
import Routes from './Routes';
import './overrides.scss';

export const organization = reducer;

const Application = () => (
  <Router>
    <Routes />
  </Router>
);

export default Application;
