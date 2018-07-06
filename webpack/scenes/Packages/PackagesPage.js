import React, { Component } from "react"
import { Grid, Row, Col, Table } from 'patternfly-react';
import packagesColumns from './columns';
import mockRows from './mockRows';

class PackagesPage extends Component {
  constructor(props) {
    super(props)
  }

  render() {
    return (
      <Grid bsClass="container-fluid">
        <div>
          <Row>
            <Col sm={12}>
              <h1>Packages</h1>
            </Col>
          </Row>
          <Row>
            <Col sm={12}>
              <Table.PfProvider
                striped
                bordered
                hover
                columns={packagesColumns}
              >
              <Table.Header/>
              <Table.Body rows={mockRows} rowKey="id" />
              </Table.PfProvider>
            </Col>
          </Row>
        </div>
      </Grid>
    )
  }
}

export default PackagesPage;
