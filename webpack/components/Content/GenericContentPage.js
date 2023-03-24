import React from 'react';
import PropTypes from 'prop-types';
import { Grid, Col, Row, Form, FormGroup } from 'react-bootstrap';
import SearchBar from 'foremanReact/components/SearchBar';
import { getControllerSearchProps } from 'foremanReact/constants';
import ContentTable from './ContentTable';
import { useClearSearch } from '../extensions/SearchBar/SearchBarHooks';

const GenericContentPage = ({
  header, onSearch, bookmarkController,
  autocompleteEndpoint, autocompleteQueryParams,
  updateSearchQuery, initialInputValue,
  content, tableSchema, onPaginationChange,
}) => {
  const searchDataProp = {
    ...getControllerSearchProps(autocompleteEndpoint, `searchBar-content-page-${header}`, true, autocompleteQueryParams),
    controller: bookmarkController,
  };
  const searchBarKey = useClearSearch({ updateSearchQuery });
  return (
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
              <SearchBar
                key={searchBarKey}
                data={searchDataProp}
                onSearch={onSearch}
                onSearchChange={updateSearchQuery}
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
};

GenericContentPage.propTypes = {
  header: PropTypes.string.isRequired,
  content: PropTypes.shape({}).isRequired,
  tableSchema: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  onSearch: PropTypes.func.isRequired,
  updateSearchQuery: PropTypes.func.isRequired,
  initialInputValue: PropTypes.string.isRequired,
  onPaginationChange: PropTypes.func.isRequired,
  autocompleteEndpoint: PropTypes.string,
  autocompleteQueryParams: PropTypes.shape({}),
  bookmarkController: PropTypes.string,
};

GenericContentPage.defaultProps = {
  autocompleteEndpoint: undefined,
  autocompleteQueryParams: undefined,
  bookmarkController: undefined,
};

export default GenericContentPage;
