import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
import Routes from './Routes';
import './overrides.scss';

export default () => (
  <Router>
    <Routes />
  </Router>
);
