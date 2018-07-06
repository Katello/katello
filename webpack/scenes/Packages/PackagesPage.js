import React, { Component } from "react"
import { Grid, Row, Col, Table } from 'patternfly-react';

const headerFormat = value => <th>{value}</th>;
const cellFormat = value => <td>{value}</td>;

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
                columns={[
                  {header: {label: 'First Name',formatters: [headerFormat]},cell: {formatters: [cellFormat]},property: 'first_name'},
                  {header: {label: 'Last Name',formatters: [headerFormat]},cell: {formatters: [cellFormat]},property: 'last_name'},
                  {header: {label: 'Username',formatters: [headerFormat]},cell: {formatters: [cellFormat]},property: 'username'},
                ]}
              >
              <Table.Header/>
              <Table.Body rows={[
                  {
                    id: 0,
                    first_name: 'Dan',
                    last_name: 'Abramov',
                  },
                  {
                    id: 1,
                    first_name: 'Sebastian',
                    last_name: 'Markbåge',
                  },
                  {
                    id: 2,
                    first_name: 'Sophie',
                    last_name: 'Alpert',
                  },
                ]} rowKey="id" />
              </Table.PfProvider>
            </Col>
          </Row>
        </div>
      </Grid>
    )
  }
}

export default PackagesPage;
