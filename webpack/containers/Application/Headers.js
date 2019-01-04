import React from '@theforeman/vendor/react';
import { Helmet } from '@theforeman/vendor/react-helmet';

const Header = props => (
  <Helmet>
    {Object.entries(props).map(([TagName, value]) =>
      <TagName key={TagName}>{value}</TagName>)};
  </Helmet>
);

export default Header;
