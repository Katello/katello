import React, { useState } from 'react';
import { FormattedMessage } from 'react-intl';
import {
  Alert,
  Grid,
  GridItem,
  CodeBlock,
  CodeBlockAction,
  CodeBlockCode,
  ClipboardCopyButton,
  ExpandableSection,
  ExpandableSectionToggle,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';

import { copyToClipboard } from '../helpers';

const ContentSourceTemplate = ({ template, jobInvocationPath }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [isCopied, setCopied] = useState(false);

  const handleCopy = (e) => {
    copyToClipboard(e, template);
    setCopied(true);
  };

  const actions = (
    <CodeBlockAction>
      <ClipboardCopyButton
        onClick={e => handleCopy(e)}
        exitDelay={600}
        maxWidth="110px"
        variant="plain"
      >
        {isCopied ? __('Copied to clipboard') : __('Copy to clipboard')}
      </ClipboardCopyButton>
    </CodeBlockAction>
  );

  return (
    <Grid>
      <GridItem span={7}>
        <Alert
          ouiaId="host-configuration-alert"
          variant="warning"
          title={__('Host configurations are not updated yet')}
          className="margin-top-20"
          isInline
        >
          <FormattedMessage
            id="ccs_alert"
            values={{
              link: <a href={jobInvocationPath}>{__('run job invocation')}</a>,
            }}
            defaultMessage={jobInvocationPath ? __('To update the selected host configuration, {link}, or update hosts manually in the next section.') : __('To update the selected host configuration, update hosts manually in the next section.')}
          />
        </Alert>

      </GridItem>
      <GridItem span={7}>
        <CodeBlock actions={actions} className="cs_template_code margin-top-20">
          <CodeBlockCode>
            {__('Change content source')}
            <ExpandableSection isExpanded={isExpanded} isDetached>
              {template}
            </ExpandableSection>
          </CodeBlockCode>
          <ExpandableSectionToggle
            isExpanded={isExpanded}
            onToggle={() => setIsExpanded(!isExpanded)}
            contentId="code-block-expand"
            direction="up"
          >
            {isExpanded ? 'Show less' : 'Show more'}
          </ExpandableSectionToggle>
        </CodeBlock>
      </GridItem>
    </Grid>);
};

ContentSourceTemplate.propTypes = {
  template: PropTypes.string,
  jobInvocationPath: PropTypes.string,
};

ContentSourceTemplate.defaultProps = {
  template: '',
  jobInvocationPath: '',
};

export default ContentSourceTemplate;
