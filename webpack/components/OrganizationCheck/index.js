import React from 'react';
import PropTypes from 'prop-types';
import { Grid, Row, Col } from 'patternfly-react';
import './index.scss';

const OrganizationCheck = (props) => {
  const { children, hide } = props;
  if (hide) {
    return (
      <Grid bsClass="container-fluid">
        <Row>
          <Col sm={12}>
            <div className="centered-message">
              <h2>No organization selected</h2>
              <h3>
                The page you are attempting to access requires a selected organization.
              </h3>
              <h3>
                Please select an organization from the dropdown in the top menu bar
                and you will be redirected.
              </h3>
            </div>
          </Col>
        </Row>
      </Grid>
    );
  }
  return (
    <div>{ children }</div>
  );
};

OrganizationCheck.propTypes = {
  hide: PropTypes.bool,
  children: PropTypes.node.isRequired,
};

OrganizationCheck.defaultProps = {
  hide: false,
};
export default OrganizationCheck;
