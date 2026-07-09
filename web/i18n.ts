import { getRequestConfig } from 'next-intl/server';

export default getRequestConfig(async ({ locale }) => {
  return {
    locale: locale || 'ar',
    messages: (await import(`./messages/${locale || 'ar'}.json`)).default,
  };
});
