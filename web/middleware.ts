import createMiddleware from 'next-intl/middleware';

export default createMiddleware({
  locales: ['ar', 'en', 'fr'],
  defaultLocale: 'ar',
  localePrefix: 'always',
  localeDetection: false,
});

export const config = {
  matcher: ['/((?!_next|api|.*\\..*).*)'],
};
