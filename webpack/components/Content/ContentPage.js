import React from 'react';
import PropTypes from 'prop-types';
import { Grid, Col, Row, Form, FormGroup } from 'react-bootstrap';
import Search from '../../components/Search/index';
import ContentTable from './ContentTable';

const ContentPage = props => (
  <Grid bsClass="container-fluid">
    <Row>
      <Col sm={12}>
        <h1>{props.header}</h1>
      </Col>
    </Row>
    <Row>
      <Col sm={6}>
        <Form className="toolbar-pf-actions">
          <FormGroup className="toolbar-pf toolbar-pf-filter">
            <Search
              onSearch={props.onSearch}
              getAutoCompleteParams={props.getAutoCompleteParams}
              updateSearchQuery={props.updateSearchQuery}
              initialInputValue={props.initialInputValue}
            />
          </FormGroup>
        </Form>
      </Col>
    </Row>
    <Row>
      <Col sm={12}>
        <ContentTable
          content={props.content}
          tableSchema={props.tableSchema}
          onPaginationChange={props.onPaginationChange}
        />
      </Col>
    </Row>
  </Grid>
);

ContentPage.propTypes = {
  props: PropTypes.shape({}).isRequired,
  header: PropTypes.string.isRequired,
  content: PropTypes.shape({}).isRequired,
  tableSchema: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  onSearch: PropTypes.func.isRequired,
  getAutoCompleteParams: PropTypes.func.isRequired,
  updateSearchQuery: PropTypes.func.isRequired,
  initialInputValue: PropTypes.string.isRequired,
  onPaginationChange: PropTypes.func.isRequired,
};

export default ContentPage;
