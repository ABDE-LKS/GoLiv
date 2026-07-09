'use client';

import { useRouter, usePathname } from 'next/navigation';
import { Globe } from 'lucide-react';
import { useState, useEffect } from 'react';

export default function LocaleSwitch() {
  const router = useRouter();
  const pathname = usePathname();
  const [isOpen, setIsOpen] = useState(false);
  const [locale, setLocale] = useState<string>('ar');
  
  useEffect(() => {
    const current = pathname.split('/')[1] || 'ar';
    setLocale(current);
  }, [pathname]);

  const locales = [
    { code: 'ar', label: 'العربية', flag: '🇸🇦' },
    { code: 'en', label: 'English', flag: '🇬🇧' },
    { code: 'fr', label: 'Français', flag: '🇫🇷' },
  ];

  const handleLocaleChange = (newLocale: string) => {
    const pathSegments = pathname.split('/');
    pathSegments[1] = newLocale;
    router.push(pathSegments.join('/'));
    setIsOpen(false);
  };

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="p-2 hover:rounded-lg transition-colors flex items-center gap-1"
        style={{ color: 'var(--foreground)' }}
        aria-label="Change language"
      >
        <Globe size={20} />
      </button>

      {isOpen && (
        <div 
          className="absolute right-0 mt-1 w-40 rounded-lg shadow-elevated z-50 overflow-hidden border"
          style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}
        >
          {locales.map((loc) => (
            <button
              key={loc.code}
              onClick={() => handleLocaleChange(loc.code)}
              className="w-full px-4 py-2.5 text-sm text-left hover:bg-muted transition-colors flex items-center gap-2 border-b"
              style={{
                backgroundColor: locale === loc.code ? 'color-mix(in srgb, var(--primary) 10%, transparent)' : 'transparent',
                borderColor: 'var(--border)',
                color: locale === loc.code ? 'var(--primary)' : 'var(--foreground)',
              }}
            >
              <span>{loc.flag}</span>
              <span className={locale === loc.code ? 'font-semibold' : ''}>{loc.label}</span>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
