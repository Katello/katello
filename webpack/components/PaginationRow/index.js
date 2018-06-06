import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Paginator } from 'patternfly-react';
import { isEqual } from 'lodash';

const defaultPerPageOptions = [5, 10, 15, 25, 50];

const initPagination = (props) => {
  const pagination = props.pagination || {};
  // The default pagination is normally returned from server.
  // This values are used only when there's some error in the server response.
  const defaultPagination = {
    page: 1,
    perPage: 10,
    perPageOptions: defaultPerPageOptions,
  };
  return { ...defaultPagination, ...pagination };
};

class PaginationRow extends Component {
  constructor(props) {
    super(props);

    this.state = initPagination(this.props);

    this.onPageSet = this.onPageSet.bind(this);
    this.onPerPageSelect = this.onPerPageSelect.bind(this);
  }

  static getDerivedStateFromProps(newProps, prevState) {
    if (!isEqual(newProps.pagination, prevState.pagination)) {
      return { ...newProps.pagination };
    }
    return null;
  }

  onPageSet(page) {
    this.update({ page });
    this.props.onPageSet(page);
  }

  onPerPageSelect(perPage) {
    this.update({ perPage, page: 1 });
    this.props.onPerPageSelect(perPage);
  }

  update(changes) {
    const newState = { ...this.state, ...changes };
    this.setState(newState);

    this.props.onChange({
      page: newState.page,
      perPage: newState.perPage,
    });
  }

  render() {
    const {
      onPageSet, onPerPageSelect, pagination, ...otherProps
    } = this.props;

    return (
      <Paginator
        {...otherProps}
        pagination={this.state}
        onPageSet={this.onPageSet}
        onPerPageSelect={this.onPerPageSelect}
      />
    );
  }
}

PaginationRow.defaultPerPageOptions = defaultPerPageOptions;

PaginationRow.defaultProps = {
  onChange: () => {},
  ...Paginator.defaultProps,
};

PaginationRow.propTypes = {
  /** page and per-page selection callback */
  onChange: PropTypes.func,
  pagination: PropTypes.shape({
    /** the current page */
    page: PropTypes.number,
    /** the current per page setting */
    perPage: PropTypes.number,
    /** per page options */
    perPageOptions: PropTypes.array,
  }),
  ...Paginator.propTypes,
};

export default PaginationRow;
