import React from '@theforeman/vendor/react';
import Header from '../Application/Headers';

function withHeader(WrappedComponent, tags) {
  const Headers = props => (
    <React.Fragment>
      <Header {...tags} />
      <WrappedComponent {...props} />
    </React.Fragment>
  );

  return Headers;
}

export default withHeader;
