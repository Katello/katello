// Date matching patternfly's specifications
// https://www.patternfly.org/v4/design-guidelines/content/grammar-and-terminology#date
// The date can be any accepted date by JavaScript's Date object and the timezone
// is any IANA timezone, which is the format Foreman uses. This means the Foreman user's
// timezone can be imported from the I18n settings and used with this function.
const dateFormatter = (date, timezone) => {
  const jsdt = new Date(date);
  console.log(jsdt)
  const day = jsdt.getDate();
  const month = jsdt.toLocaleDateString('en-US', { month: 'short' });
  const year = jsdt.getFullYear();
  const formatterOptions = {
    hour12: false,
    timeZone: timezone,
    timeZoneName: 'short',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  };

  // Format date to 24H time with shortened timezone and user-set timezone passed in
  const formatter = new Intl.DateTimeFormat('en-US', formatterOptions);
  const time = formatter.format(new Date(jsdt.toGMTString()));

  const formatted = `${day} ${month} ${year}, ${time}`;

  return formatted;
};

export default dateFormatter;
