import React from 'react';
import { Helmet } from 'react-helmet';

const Header = props => (
  <Helmet>
    {Object.entries(props).map(([TagName, value]) =>
      <TagName key={TagName}>{value}</TagName>)};
  </Helmet>
);

export default Header;
