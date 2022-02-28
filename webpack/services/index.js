// eslint-disable-next-line import/prefer-default-export
export function getTypeIcon(type) {
  const typeIcon = { name: '', type: '' };

  switch (type) {
  case 'yum':
    typeIcon.name = 'bundle';
    typeIcon.type = 'pf';
    break;
  case 'source_rpm':
    typeIcon.name = 'code';
    typeIcon.type = 'fa';
    break;
  case 'file':
    typeIcon.name = 'file';
    typeIcon.type = 'fa';
    break;
  case 'debug':
    typeIcon.name = 'bug';
    typeIcon.type = 'fa';
    break;
  case 'iso':
    typeIcon.name = 'file-image-o';
    typeIcon.type = 'fa';
    break;
  case 'beta':
    typeIcon.name = 'bold';
    typeIcon.type = 'fa';
    break;
  case 'kickstart':
    typeIcon.name = 'futbol-o';
    typeIcon.type = 'fa';
    break;
  case 'containerimage':
    typeIcon.name = 'cube';
    typeIcon.type = 'fa';
    break;
  default:
    typeIcon.name = 'question';
    typeIcon.type = 'fa';
    break;
  }
  return typeIcon;
}
