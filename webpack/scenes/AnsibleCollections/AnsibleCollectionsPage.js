import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Grid, Col, Row, Form, FormGroup } from 'react-bootstrap';
import qs from 'query-string';
import Search from '../../components/Search/index';
import AnsibleCollectionsTable from './AnsibleCollectionsTable';
import { orgId } from '../../services/api';

class AnsibleCollectionsPage extends Component {
  constructor(props) {
    super(props);

    const queryParams = qs.parse(this.props.location.search);
    this.state = {
      searchQuery: queryParams.search || '',
    };
  }

  componentDidMount() {
    this.props.getAnsibleCollections({
      search: this.state.searchQuery,
    });
  }

  onPaginationChange = (pagination) => {
    this.props.getAnsibleCollections({
      ...pagination,
    });
  };

  onSearch = (search) => {
    this.props.getAnsibleCollections({ search });
  };

  getAutoCompleteParams = search => ({
    endpoint: '/ansible_collections/auto_complete_search',
    params: {
      organization_id: orgId(),
      search,
    },
  });

  updateSearchQuery = (searchQuery) => {
    this.setState({ searchQuery });
  };

  render() {
    const { ansibleCollections } = this.props;
    return (
      <Grid bsClass="container-fluid">
        <Row>
          <Col sm={12}>
            <h1>{__('Ansible Collections')}</h1>
          </Col>
        </Row>
        <Row>
          <Col sm={6}>
            <Form className="toolbar-pf-actions">
              <FormGroup className="toolbar-pf toolbar-pf-filter">
                <Search
                  onSearch={this.onSearch}
                  getAutoCompleteParams={this.getAutoCompleteParams}
                  updateSearchQuery={this.updateSearchQuery}
                  initialInputValue={this.state.searchQuery}
                />
              </FormGroup>
            </Form>
          </Col>
        </Row>
        <Row>
          <Col sm={12}>
            <AnsibleCollectionsTable
              ansibleCollections={ansibleCollections}
              onPaginationChange={this.onPaginationChange}
            />
          </Col>
        </Row>
      </Grid>
    );
  }
}

AnsibleCollectionsPage.propTypes = {
  location: PropTypes.shape({
    search: PropTypes.oneOfType([
      PropTypes.shape({}),
      PropTypes.string,
    ]),
  }),
  getAnsibleCollections: PropTypes.func.isRequired,
  ansibleCollections: PropTypes.shape({}).isRequired,
};

AnsibleCollectionsPage.defaultProps = {
  location: { search: '' },
};


export default AnsibleCollectionsPage;
