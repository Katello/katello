// webpack/scenes/FlatpakRemoteInfo/FlatpakRemoteConstants.js
import { translate as __ } from 'foremanReact/common/I18n';

const FLATPAK_REMOTE_KEY = 'FLATPAK_REMOTE';
export const GET_FLATPAK_REMOTE_INFO_KEY = `${FLATPAK_REMOTE_KEY}_GET`;
export const GET_FLATPAK_REMOTE_STATUS_KEY = `${FLATPAK_REMOTE_KEY}_STATUS`;
export const GET_FLATPAK_REMOTE_ERROR_KEY = `${FLATPAK_REMOTE_KEY}_ERROR`;

// Function to append id to FLATPAK_REMOTE_KEY using arrow syntax
export const getFlatpakRemoteDetailsKey = (id) =>  `${FLATPAK_REMOTE_KEY}_${id}`;

export default FLATPAK_REMOTE_KEY;