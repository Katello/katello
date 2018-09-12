import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Grid, Row, Col, Form, FormGroup } from 'react-bootstrap';
import Search from '../../components/Search/index';
import ModuleStreamsTable from './ModuleStreamsTable';
import { orgId } from '../../services/api';

const qs = require('query-string');

class ModuleStreamsPage extends Component {
  constructor(props) {
    super(props);

    const queryParams = qs.parse(this.props.location.search);
    this.state = {
      searchQuery: queryParams.search || '',
    };
  }

  componentDidMount() {
    this.props.getModuleStreams({
      search: this.state.searchQuery,
    });
  }

  onPaginationChange = (pagination) => {
    this.props.getModuleStreams({
      ...pagination,
    });
  };

  onSearch = (search) => {
    this.props.getModuleStreams({ search });
  };

  getAutoCompleteParams = search => ({
    endpoint: '/module_streams/auto_complete_search',
    params: {
      organization_id: orgId(),
      search,
    },
  });

  updateSearchQuery = (searchQuery) => {
    this.setState({ searchQuery });
  };

  render() {
    const { moduleStreams } = this.props;
    return (
      <Grid bsClass="container-fluid">
        <Row>
          <Col sm={12}>
            <h1>{__('Module Streams')}</h1>
          </Col>
        </Row>
        <Row>
          <Col sm={6}>
            <Form className="toolbar-pf-actions">
              <FormGroup className="toolbar-pf-filter">
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
            <ModuleStreamsTable
              moduleStreams={moduleStreams}
              onPaginationChange={this.onPaginationChange}
            />
          </Col>
        </Row>
      </Grid>
    );
  }
}

ModuleStreamsPage.propTypes = {
  location: PropTypes.shape({
    search: PropTypes.oneOfType([
      PropTypes.shape({}),
      PropTypes.string,
    ]),
  }),
  getModuleStreams: PropTypes.func.isRequired,
  moduleStreams: PropTypes.shape({}).isRequired,
};

ModuleStreamsPage.defaultProps = {
  location: { search: '' },
};

export default ModuleStreamsPage;
