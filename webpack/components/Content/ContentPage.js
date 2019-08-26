import React from 'react';
import PropTypes from 'prop-types';
import { Grid, Col, Row, Form, FormGroup } from 'react-bootstrap';
import Search from '../../components/Search/index';
import ContentTable from './ContentTable';

const ContentPage = ({
  header, onSearch, getAutoCompleteParams,
  updateSearchQuery, initialInputValue,
  content, tableSchema, onPaginationChange,
}) => (
  <Grid bsClass="container-fluid">
    <Row>
      <Col sm={12}>
        <h1>{header}</h1>
      </Col>
    </Row>
    <Row>
      <Col sm={6}>
        <Form className="toolbar-pf-actions">
          <FormGroup className="toolbar-pf toolbar-pf-filter">
            <Search
              onSearch={onSearch}
              getAutoCompleteParams={getAutoCompleteParams}
              updateSearchQuery={updateSearchQuery}
              initialInputValue={initialInputValue}
            />
          </FormGroup>
        </Form>
      </Col>
    </Row>
    <Row>
      <Col sm={12}>
        <ContentTable
          content={content}
          tableSchema={tableSchema}
          onPaginationChange={onPaginationChange}
        />
      </Col>
    </Row>
  </Grid>
);

ContentPage.propTypes = {
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
