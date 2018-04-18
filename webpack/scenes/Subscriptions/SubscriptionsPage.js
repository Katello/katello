import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { LinkContainer } from 'react-router-bootstrap';
import { Grid, Row, Col, Form, FormGroup } from 'react-bootstrap';
import { Button, Spinner } from 'patternfly-react';
import Table from '../../move_to_foreman/components/common/table';
import PaginationRow from '../../components/PaginationRow/index';
import ManageManifestModal from './Manifest/';
import { columns } from './SubscriptionsTableSchema';
import Search from '../../components/Search/index';
import { orgId } from '../../services/api';
import { BLOCKING_FOREMAN_TASK_TYPES, MANIFEST_TASKS_BULK_SEARCH_ID } from './SubscriptionConstants';

class SubscriptionsPage extends Component {
  constructor(props) {
    super(props);

    this.state = {
      manifestModalOpen: false,
    };
  }

  componentDidMount() {
    this.loadData();
  }

  loadData() {
    this.props.pollBulkSearch({
      search_id: MANIFEST_TASKS_BULK_SEARCH_ID,
      type: 'all',
      active_only: true,
      action_types: BLOCKING_FOREMAN_TASK_TYPES,
    }, 10000);
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
    const { tasks } = this.props;
    const taskInProgress = tasks.length > 0;

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

    const showManageManifestModal = () => {
      this.setState({ manifestModalOpen: true });
    };

    const onModalClose = () => {
      this.setState({ manifestModalOpen: false });
    };

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

                      <Button disabled={taskInProgress} onClick={showManageManifestModal}>
                        {__('Manage Manifest')}
                      </Button>

                      <Button>
                        {__('Export CSV')}
                      </Button>

                      <Button disabled={taskInProgress}>
                        {__('Delete')}
                      </Button>
                    </FormGroup>
                  </div>
                </Form>
              </Col>
            </Row>

            <ManageManifestModal showModal={this.state.manifestModalOpen} onClose={onModalClose} />

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
  pollBulkSearch: PropTypes.func.isRequired,
  tasks: PropTypes.arrayOf(PropTypes.shape({})),
};

SubscriptionsPage.defaultProps = {
  tasks: [],
};

export default SubscriptionsPage;
