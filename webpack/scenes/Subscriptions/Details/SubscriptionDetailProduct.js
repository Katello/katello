import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col } from 'patternfly-react';
import { translate as __ } from 'foremanReact/common/I18n';

const SubscriptionDetailProduct = ({ content }) => (
  <Row key={content.id}>
    <Col sm={12}>
      <Row>
        <u>{content.name}</u>
      </Row>
    </Col>
    <Row>
      <Col sm={3}>{__('Content Download URL')}</Col>
      <Col sm={9}>{content.content_url} </Col>
    </Row>
    <Row>
      <Col sm={3}>{__('GPG Key URL')}</Col>
      <Col sm={9}>{content.gpg_url} </Col>
    </Row>
    <Row>
      <Col sm={3}>{__('Repo Type')}</Col>
      <Col sm={9}>{content.type} </Col>
    </Row>
    <Row>
      <Col sm={3}>{__('Enabled')}</Col>
      <Col sm={9}>{content.enabled ? __('yes') : __('no')} </Col>
    </Row>
  </Row>
);

SubscriptionDetailProduct.propTypes = {
  content: PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.string,
    enabled: PropTypes.bool,
    content_url: PropTypes.string,
    gpg_url: PropTypes.string,
    type: PropTypes.string,
    enable: PropTypes.bool,
  }).isRequired,
};

export default SubscriptionDetailProduct;
