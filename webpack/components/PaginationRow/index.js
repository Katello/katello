import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { PaginationRow } from 'patternfly-react';
import { isEqual } from 'lodash';

import { propsToState, mapStateToProps } from './helpers';

class RepoSetsPagination extends Component {
  constructor(props) {
    super(props);

    this.state = propsToState(props.config);

    this.onPageInput = this.onPageInput.bind(this);
    this.onPerPageSelect = this.onPerPageSelect.bind(this);
    this.onPreviousPage = this.onPreviousPage.bind(this);
    this.onNextPage = this.onNextPage.bind(this);
    this.onFirstPage = this.onFirstPage.bind(this);
    this.onLastPage = this.onLastPage.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    const calculatedState = propsToState(nextProps.config);
    if (!isEqual(calculatedState, this.state)) {
      this.setState(calculatedState);
    }
  }

  onPageInput(e) {
    const newPage = parseInt(e.target.value, 10);
    if (newPage && !Number.isNaN(newPage) && newPage <= this.state.amountOfPages) {
      this.update({ page: newPage });
    }
  }

  onPerPageSelect(eventKey) {
    this.update({ perPage: eventKey });
  }

  onPreviousPage() {
    const newPage = this.state.page - 1;
    if (newPage >= 1) {
      this.update({ page: newPage });
    }
  }

  onNextPage() {
    const newPage = this.state.page + 1;
    if (newPage <= this.state.amountOfPages) {
      this.update({ page: newPage });
    }
  }

  onFirstPage() {
    if (this.state.page > 1) {
      this.update({ page: 1 });
    }
  }

  onLastPage() {
    if (this.state.page < this.state.amountOfPages) {
      this.update({ page: this.state.amountOfPages });
    }
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
      page, perPage, amountOfPages, itemCount, itemsStart, itemsEnd,
    } = this.state;

    return (
      <div>
        <PaginationRow
          viewType={this.props.viewType}
          pagination={{
            page,
            perPage,
            perPageOptions: [5, 10, 20, 25, 50],
          }}
          amountOfPages={amountOfPages}
          itemCount={itemCount}
          itemsStart={itemsStart}
          itemsEnd={itemsEnd}
          onPerPageSelect={this.onPerPageSelect}
          onPreviousPage={this.onPreviousPage}
          onPageInput={this.onPageInput}
          onNextPage={this.onNextPage}
          onFirstPage={this.onFirstPage}
          onLastPage={this.onLastPage}
        />
      </div>
    );
  }
}

RepoSetsPagination.propTypes = {
  viewType: PropTypes.oneOf(['list', 'card', 'table']),
  onChange: PropTypes.func.isRequired,
  config: PropTypes.shape({}).isRequired,
  // page: PropTypes.number.isRequired,
  // amountOfPages: PropTypes.number.isRequired,
  // itemCount: PropTypes.number.isRequired,
  // itemsStart: PropTypes.number.isRequired,
  // itemsEnd: PropTypes.number.isRequired,
  // perPage: PropTypes.number,
};

RepoSetsPagination.defaultProps = {
  viewType: 'list',
};

export default connect(mapStateToProps)(RepoSetsPagination);
