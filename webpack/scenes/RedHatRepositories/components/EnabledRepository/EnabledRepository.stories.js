import React from '@theforeman/vendor/react';
import { storiesOf } from '@storybook/react';
import EnabledRepository from './EnabledRepository.js';

storiesOf('RedHat Repositories Page', module).add('Enabled Repository', () => (
  <EnabledRepository
    id={638}
    name="Red Hat Enterprise Linux 6 Server Kickstart x86_64 6.8"
    releasever="6.8"
    arch="x86_64"
    type="rpm"
  />
));
