import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { LinkContainer } from 'react-router-bootstrap';
import { Grid, Row, Col, Form, FormGroup, FormControl, ControlLabel } from 'react-bootstrap';
import { Button, Spinner } from 'patternfly-react';
import Table from 'foremanReact/components/common/table';
import PaginationRow from '../../components/PaginationRow/index';
import { columns } from './SubscriptionsTableSchema';

class SubscriptionsPage extends Component {
  componentDidMount() {
    this.loadData();
  }

  loadData() {
    this.props.loadSubscriptions();
  }

  render() {
    const { subscriptions } = this.props;

    const onPaginationChange = (pagination) => {
      this.props.loadSubscriptions({
        ...pagination,
      });
    };

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

    return (
      <Grid bsClass="container-fluid">
        <Row>
          <Col sm={12}>
            <h1>{__('Red Hat Subscriptions')}</h1>

            <Row className="toolbar-pf table-view-pf-toolbar-external">
              <Col sm={12}>
                <Form className="toolbar-pf-actions">
                  <FormGroup className="toolbar-pf-filter">
                    <ControlLabel srOnly>{__('Search')}</ControlLabel>
                    <FormControl type="text" placeholder={__('Filter')} />
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

            <Spinner loading={subscriptions.loading} className="small-spacer">
              <Table
                rows={subscriptions.results}
                columns={columns}
                emptyState={emptyStateData()}
              />
              <PaginationRow
                viewType="table"
                itemCount={subscriptions.pagination.total}
                pagination={subscriptions.pagination}
                onChange={onPaginationChange}
              />
            </Spinner>
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
