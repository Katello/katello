import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col } from 'patternfly-react';

const SubscriptionDetailProduct = ({ content }) => (
  <Row key={content.id}>
    <Col sm={12}>
      <Row><u>{content.name}</u></Row>
    </Col>
    <Col sm={3}>
      <Row>{ __('Content Download URL') }</Row>
      <Row>{ __('GPG Key URL') }</Row>
      <Row>{ __('Repo Type') }</Row>
      <Row>{ __('Enabled?') }</Row>
    </Col>
    <Col sm={9}>
      <Row>{content.content_url}</Row>
      <Row>{content.gpg_url}</Row>
      <Row>{content.type}</Row>
      <Row>{content.enabled ? __('yes') : __('no')}</Row>
    </Col>
  </Row>
);

SubscriptionDetailProduct.propTypes = {
  content: PropTypes.shape({}).isRequired,
};

export default SubscriptionDetailProduct;
