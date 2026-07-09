export const locales = ['ar', 'en', 'fr'] as const;
export const defaultLocale = 'ar' as const;
export type Locale = typeof locales[number];

// Load messages dynamically
async function loadMessages(locale: Locale) {
  try {
    const module = await import(`../messages/${locale}.json`);
    return module.default;
  } catch {
    return {};
  }
}

// Cache for loaded messages
const messageCache: Partial<Record<Locale, any>> = {};

export async function getMessages(locale: Locale) {
  if (!messageCache[locale]) {
    messageCache[locale] = await loadMessages(locale);
  }
  return messageCache[locale];
}

export async function getMessageSync(locale: Locale) {
  const map: Record<Locale, any> = {
    ar: require('../messages/ar.json'),
    en: require('../messages/en.json'),
    fr: require('../messages/fr.json'),
  };
  return map[locale] || {};
}

export function t(locale: Locale, key: string | undefined): string {
  if (!key || typeof key !== 'string') return '';
  
  // Static require for SSR
  const messages: Record<Locale, any> = {
    ar: {
      "nav": {
        "signIn": "تسجيل الدخول",
        "getStarted": "ابدأ الآن",
        "marketplace": "السوق",
        "services": "الخدمات",
        "jobs": "الوظائف",
        "myListings": "إعلاناتي",
        "messages": "الرسائل",
        "profile": "الملف الشخصي",
        "settings": "الإعدادات",
        "logout": "تسجيل الخروج"
      },
      "home": {
        "title": "سوقك المحلي",
        "description": "اشترِ وبع وأستأجر الخدمات في مجتمعك. يربط GoLiv الجزائريين بالعروض والخدمات المحلية الموثوقة.",
        "browseListings": "تصفح الإعلانات",
        "startSelling": "ابدأ البيع",
        "howItWorks": "كيف يعمل GoLiv",
        "marketplace": "السوق",
        "marketplaceDesc": "تصفح آلاف الإعلانات من البائعين المحليين الموثوقين. انشر إعلاناتك الخاصة في دقائق.",
        "services": "الخدمات",
        "servicesDesc": "تواصل مع متخصصين مهرة في السباكة والكهرباء والتنظيف والمزيد.",
        "jobs": "الوظائف",
        "jobsDesc": "اكتشف فرص عمل محلية وتواصل مع أصحاب العمل في منطقتك.",
        "whyChoose": "لماذا تختار GoLiv؟",
        "verified": "مستخدمون موثوقون",
        "verifiedDesc": "معاملات آمنة مع بائعين وعملاء موثوقين",
        "fast": "سريع وسهل",
        "fastDesc": "انشر الإعلانات أو ابحث عن الخدمات في دقائق فقط",
        "community": "المجتمع المحلي",
        "communityDesc": "ادعم المشاريع المحلية والجيران في منطقتك",
        "getStartedToday": "ابدأ اليوم",
        "joinThousands": "انضم إلى آلاف الجزائريين الذين يستخدمون GoLiv للشراء والبيع والتوظيف.",
        "noCreditCard": "لا تحتاج بطاقة ائتمان",
        "activeUsers": "مستخدمون نشطون",
        "listings": "إعلانات منشورة",
        "satisfactionRate": "معدل الرضا",
        "explore": "استكشف",
        "company": "الشركة",
        "legal": "القانوني",
        "about": "عن GoLiv",
        "blog": "المدونة",
        "contact": "اتصل بنا",
        "privacy": "سياسة الخصوصية",
        "terms": "شروط الاستخدام",
        "safety": "الأمان",
        "copyright": "© 2025 GoLiv. جميع الحقوق محفوظة. تم تطويره للجزائر."
      },
      "auth": {
        "register": "إنشاء حساب",
        "alreadyHaveAccount": "هل لديك حساب بالفعل؟",
        "login": "تسجيل الدخول",
        "noCardRequired": "لا تحتاج بطاقة ائتمان"
      },
      "why": {
        "choose": "لماذا تختار GoLiv؟"
      },
      "stats": {
        "satisfactionRate": "معدل الرضا",
        "activeUsers": "مستخدمون نشطون",
        "listings": "إعلانات منشورة"
      }
    },
    en: {
      "nav": {
        "signIn": "Sign In",
        "getStarted": "Get Started",
        "marketplace": "Marketplace",
        "services": "Services",
        "jobs": "Jobs",
        "myListings": "My Listings",
        "messages": "Messages",
        "profile": "Profile",
        "settings": "Settings",
        "logout": "Logout"
      },
      "home": {
        "title": "Your Local Marketplace",
        "description": "Buy, sell, and hire services in your community. GoLiv connects Algerians to trusted local deals and services.",
        "browseListings": "Browse Listings",
        "startSelling": "Start Selling",
        "howItWorks": "How GoLiv Works",
        "marketplace": "Marketplace",
        "marketplaceDesc": "Browse thousands of listings from verified local sellers. Post your own items in minutes.",
        "services": "Services",
        "servicesDesc": "Connect with skilled professionals for repairs, cleaning, and local services.",
        "jobs": "Job Board",
        "jobsDesc": "Discover local job opportunities and connect with employers in your area.",
        "whyChoose": "Why Choose GoLiv?",
        "verified": "Verified Users",
        "verifiedDesc": "Secure transactions with verified sellers and buyers",
        "fast": "Fast & Easy",
        "fastDesc": "Post items or find services in minutes",
        "community": "Local Community",
        "communityDesc": "Support local businesses and neighbors",
        "getStartedToday": "Get Started Today",
        "joinThousands": "Join thousands of Algerians using GoLiv to buy, sell, and connect locally.",
        "noCreditCard": "No credit card required",
        "activeUsers": "Active Users",
        "listings": "Listings Posted",
        "satisfactionRate": "Satisfaction Rate",
        "explore": "Explore",
        "company": "Company",
        "legal": "Legal",
        "about": "About",
        "blog": "Blog",
        "contact": "Contact",
        "privacy": "Privacy",
        "terms": "Terms",
        "safety": "Safety",
        "copyright": "© 2025 GoLiv. All rights reserved. Made for Algeria."
      },
      "auth": {
        "register": "Create Account",
        "alreadyHaveAccount": "Already have an account?",
        "login": "Sign In",
        "noCardRequired": "No credit card required"
      },
      "why": {
        "choose": "Why Choose GoLiv?"
      },
      "stats": {
        "satisfactionRate": "Satisfaction Rate",
        "activeUsers": "Active Users",
        "listings": "Listings Posted"
      }
    },
    fr: {
      "nav": {
        "signIn": "Se Connecter",
        "getStarted": "Commencer",
        "marketplace": "Marché",
        "services": "Services",
        "jobs": "Emplois",
        "myListings": "Mes Annonces",
        "messages": "Messages",
        "profile": "Profil",
        "settings": "Paramètres",
        "logout": "Déconnexion"
      },
      "home": {
        "title": "Votre Marché Local",
        "description": "Achetez, vendez et louez des services dans votre communauté. GoLiv connecte les Algériens à des offres et services locaux fiables.",
        "browseListings": "Parcourir les Annonces",
        "startSelling": "Commencer à Vendre",
        "howItWorks": "Comment Fonctionne GoLiv",
        "marketplace": "Marché",
        "marketplaceDesc": "Parcourez des milliers d'annonces de vendeurs locaux vérifiés. Publiez vos annonces en quelques minutes.",
        "services": "Services",
        "servicesDesc": "Connectez-vous avec des professionnels qualifiés pour les réparations, le nettoyage et les services locaux.",
        "jobs": "Offres d'Emploi",
        "jobsDesc": "Découvrez les opportunités d'emploi locales et connectez-vous avec les employeurs de votre région.",
        "whyChoose": "Pourquoi Choisir GoLiv?",
        "verified": "Utilisateurs Vérifiés",
        "verifiedDesc": "Transactions sécurisées avec des vendeurs et acheteurs vérifiés",
        "fast": "Rapide et Facile",
        "fastDesc": "Publiez des annonces ou trouvez des services en quelques minutes",
        "community": "Communauté Locale",
        "communityDesc": "Soutenez les entreprises locales et les voisins",
        "getStartedToday": "Commencer Aujourd'hui",
        "joinThousands": "Rejoignez des milliers d'Algériens utilisant GoLiv pour acheter, vendre et se connecter localement.",
        "noCreditCard": "Aucune carte de crédit requise",
        "activeUsers": "Utilisateurs Actifs",
        "listings": "Annonces Publiées",
        "satisfactionRate": "Taux de Satisfaction",
        "explore": "Explorer",
        "company": "Entreprise",
        "legal": "Juridique",
        "about": "À Propos",
        "blog": "Blog",
        "contact": "Contact",
        "privacy": "Confidentialité",
        "terms": "Conditions",
        "safety": "Sécurité",
        "copyright": "© 2025 GoLiv. Tous droits réservés. Fait pour l'Algérie."
      },
      "auth": {
        "register": "Créer un Compte",
        "alreadyHaveAccount": "Vous avez déjà un compte?",
        "login": "Se Connecter",
        "noCardRequired": "Aucune carte de crédit requise"
      },
      "why": {
        "choose": "Pourquoi Choisir GoLiv?"
      },
      "stats": {
        "satisfactionRate": "Taux de Satisfaction",
        "activeUsers": "Utilisateurs Actifs",
        "listings": "Annonces Publiées"
      }
    }
  };
  
  const parts = key.split('.');
  let value: any = messages[locale];
  
  for (const part of parts) {
    if (!part) continue;
    value = value?.[part];
    if (!value) break;
  }
  
  return typeof value === 'string' ? value : key;
}
