import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Form, Button } from 'patternfly-react';
import { withRouter } from 'react-router';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import Select from '../../move_to_pf/Select/Select';
import * as SelectOrgActions from './SelectOrgAction';
import reducer from './SelectOrgReducer';
import { LoadingState } from '../../move_to_pf/LoadingState';
import './SelectOrg.scss';

class SetOrganization extends Component {
  constructor(props) {
    super(props);
    this.onSelectItem = this.onSelectItem.bind(this);
    this.onSend = this.onSend.bind(this);
    this.state = { disabled: true };
  }

  componentDidMount() {
    this.props.getOrganiztionsList();
  }

  onSelectItem(e) {
    this.setState({
      item: e.target.options[e.target.selectedIndex].text,
      id: e.target.value,
      disabled: false,
    });
  }

  onSend() {
    const {
      history,
      changeCurrentOrgaziation,
      redirectPath,
    } = this.props;
    const { id, item } = this.state;

    changeCurrentOrgaziation(`${id}-${item}`).then(() =>
      history.push({
        pathname: redirectPath,
        state: { orgChanged: this.state.item },
      }));
  }

  render() {
    const {
      list,
      loading,
    } = this.props;

    return (
      <div id="select-org" className="well col-sm-6 col-sm-offset-3">
        <LoadingState loading={loading} loadingText={__('Loading')}>
          <Form>
            <h1 className="text-center">{__('Select an Organization')}</h1>
            <p className="text-center">
              {__('The page you are attempting to access requires selecting a specific organization.')}
            </p>
            <p className="text-center">
              {__('Please select one from the list below and you will be redirected.')}
            </p>

            <div className="form-group">
              <div className="col-sm-6 col-sm-offset-3">
                <Select
                  value={this.state.id}
                  placeholder={__('Select an organization')}
                  id="organization"
                  name="organization"
                  className="form-control"
                  options={list}
                  onChange={this.onSelectItem}
                />

              </div>

              <div className="col-sm-3">
                <Button disabled={this.state.disabled} className="btn btn-primary" onClick={this.onSend}>
                  {__('Select')}
                </Button>
              </div>
            </div>
          </Form>
        </LoadingState>
      </div>
    );
  }
}


SetOrganization.propTypes = {
  list: PropTypes.arrayOf(PropTypes.object),
  loading: PropTypes.bool.isRequired,
  changeCurrentOrgaziation: PropTypes.func.isRequired,
  history: PropTypes.shape({}).isRequired,
  redirectPath: PropTypes.string.isRequired,
  getOrganiztionsList: PropTypes.func.isRequired,
};

SetOrganization.defaultProps = {
  list: [],
};

const mapStateToProps = state => ({
  orgId: state.katello.setOrganization.currentId,
  list: state.katello.setOrganization.list,
  loading: state.katello.setOrganization.loading,
});
export const setOrganization = reducer;
const mapDispatchToProps = dispatch =>
  bindActionCreators(SelectOrgActions, dispatch);

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(SetOrganization));
