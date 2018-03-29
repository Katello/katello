import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { LinkContainer } from 'react-router-bootstrap';
import { Grid, Row, Col, Form, FormGroup } from 'react-bootstrap';
import { Button, Spinner } from 'patternfly-react';
import Table from '../../move_to_foreman/components/common/table';
import PaginationRow from '../../components/PaginationRow/index';
import { columns } from './SubscriptionsTableSchema';
import Search from '../../components/Search/index';
import { orgId } from '../../services/api';

class SubscriptionsPage extends Component {
  componentDidMount() {
    this.loadData();
  }

  loadData() {
    this.props.loadSubscriptions();
  }

  renderSubscriptionTable() {
    const { subscriptions } = this.props;

    const emptyStateData = () => ({
      header: __('There are no Subscriptions to display'),
      description: __('Add Subscriptions to this Allocation to manage your Entitlements.'),
      documentation: {
        title: __('Learn more about adding Subscriptions to Allocations'),
        url: 'http://redhat.com',
      },
      action: {
        title: __('Add Subscriptions'),
        url: 'subscriptions/add',
      },
    });

    const onPaginationChange = (pagination) => {
      this.props.loadSubscriptions({
        ...pagination,
      });
    };

    let bodyMessage;
    if (subscriptions.results.length === 0 && subscriptions.searchIsActive) {
      bodyMessage = __('No subscriptions match your search criteria.');
    }

    return (
      <Spinner loading={subscriptions.loading} className="small-spacer">
        <Table
          rows={subscriptions.results}
          columns={columns}
          emptyState={emptyStateData()}
          bodyMessage={bodyMessage}
        />
        <PaginationRow
          viewType="table"
          itemCount={subscriptions.itemCount}
          pagination={subscriptions.pagination}
          onChange={onPaginationChange}
        />
      </Spinner>
    );
  }

  render() {
    const onSearch = (search) => {
      this.props.loadSubscriptions({ search });
    };

    const getAutoCompleteParams = search => ({
      endpoint: '/subscriptions/auto_complete_search',
      params: {
        organization_id: orgId,
        search,
      },
    });

    return (
      <Grid bsClass="container-fluid">
        <Row>
          <Col sm={12}>
            <h1>{__('Red Hat Subscriptions')}</h1>

            <Row className="toolbar-pf table-view-pf-toolbar-external">
              <Col sm={12}>
                <Form className="toolbar-pf-actions">
                  <FormGroup className="toolbar-pf-filter">
                    <Search onSearch={onSearch} getAutoCompleteParams={getAutoCompleteParams} />
                  </FormGroup>

                  <div className="toolbar-pf-action-right">
                    <FormGroup>
                      <LinkContainer to="subscriptions/add">
                        <Button bsStyle="primary">
                          {__('Add Subscriptions')}
                        </Button>
                      </LinkContainer>

                      <Button>
                        {__('Refresh')}
                      </Button>

                      <Button>
                        {__('Manage Manifest')}
                      </Button>

                      <Button>
                        {__('Export CSV')}
                      </Button>

                      <Button>
                        {__('Delete')}
                      </Button>
                    </FormGroup>
                  </div>
                </Form>
              </Col>
            </Row>

            { this.renderSubscriptionTable() }
          </Col>
        </Row>
      </Grid>
    );
  }
}

SubscriptionsPage.propTypes = {
  loadSubscriptions: PropTypes.func.isRequired,
  subscriptions: PropTypes.shape({}).isRequired,
};

export default SubscriptionsPage;
