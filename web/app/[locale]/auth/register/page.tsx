'use client';

import { useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import Link from 'next/link';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useAuthStore } from '@/stores/authStore';
import { authService } from '@/lib/services/authService';
import { isValidPhoneNumber } from '@/lib/utils/helpers';
import { AlertCircle, Loader2, UserPlus, ArrowLeft } from 'lucide-react';

const registerSchema = z.object({
  firstName: z.string().min(2, 'First name required'),
  lastName: z.string().min(2, 'Last name required'),
  email: z.string().email('Invalid email').optional().or(z.literal('')),
  phone: z.string().refine(isValidPhoneNumber, 'Invalid phone number'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
});

type RegisterFormData = z.infer<typeof registerSchema>;

export default function RegisterPage() {
  const router = useRouter();
  const params = useParams();
  const locale = (params?.locale as string) || 'ar';
  const { setAuth, setError, error } = useAuthStore();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<RegisterFormData>({
    resolver: zodResolver(registerSchema),
  });

  const onSubmit = async (data: RegisterFormData) => {
    setIsSubmitting(true);
    try {
      const response = await authService.register({
        email: data.email || undefined,
        password: data.password,
        firstName: data.firstName,
        lastName: data.lastName,
        phone: data.phone,
      });

      // 1. Update Zustand store
      setAuth(response);

      // 2. Write DIRECTLY to localStorage (guaranteed synchronous)
      localStorage.setItem('goliv-auth', JSON.stringify({
        state: {
          user: response.user,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken ?? null,
        },
        version: 0,
      }));

      // 3. Full page reload to dashboard
      window.location.href = `/${locale}/dashboard`;

    } catch (err: any) {
      const message = err.response?.data?.message || 'فشل التسجيل. يرجى المحاولة مرة أخرى.';
      setError(message);
    } finally {
      setIsSubmitting(false);
    }
  };


  return (
    <>
      <div className="mb-6 text-center pt-2">
        <h1 className="heading-1 text-foreground mb-2">إنشاء حساب</h1>
        <p className="subtitle">
          انضم إلى أكبر منصة محلية في الجزائر اليوم مجاناً.
        </p>
      </div>

      {error && (
        <div className="mb-6 p-4 rounded-xl flex gap-3 overflow-hidden shadow-sm items-center" style={{ backgroundColor: 'color-mix(in srgb, var(--destructive) 10%, transparent)', border: '1px solid color-mix(in srgb, var(--destructive) 30%, transparent)' }}>
          <AlertCircle style={{ color: 'var(--destructive)' }} size={20} />
          <p className="text-sm font-medium" style={{ color: 'var(--destructive)' }}>{error}</p>
        </div>
      )}

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        {/* First & Last Name */}
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-1.5">
            <label className="block text-sm font-semibold text-foreground">الاسم الأول</label>
            <input
              type="text"
              placeholder="أحمد"
              disabled={isSubmitting}
              {...register('firstName')}
              className="input-base"
            />
          </div>
          <div className="space-y-1.5">
            <label className="block text-sm font-semibold text-foreground">اللقب</label>
            <input
              type="text"
              placeholder="محمد"
              disabled={isSubmitting}
              {...register('lastName')}
              className="input-base"
            />
          </div>
        </div>

        {/* Phone */}
        <div className="space-y-1.5">
          <label className="block text-sm font-semibold text-foreground">رقم الهاتف</label>
          <div className="relative group">
            <input
              type="tel"
              placeholder="0555555555"
              dir="ltr"
              disabled={isSubmitting}
              {...register('phone')}
              className="input-base pr-12 w-full text-left font-sans tracking-wide"
            />
            <div className="absolute right-4 top-1/2 -translate-y-1/2 text-muted-foreground font-semibold text-sm select-none pointer-events-none" dir="ltr">
              DZ +213
            </div>
          </div>
          {errors.phone && (
            <p className="text-sm font-medium flex items-center gap-1.5 mt-1" style={{ color: 'var(--destructive)' }}>
              <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: 'var(--destructive)' }} />
              يرجى إدخال رقم هاتف صحيح
            </p>
          )}
        </div>

        {/* Email */}
        <div className="space-y-1.5">
          <div className="flex items-center justify-between">
            <label className="block text-sm font-semibold text-foreground">البريد الإلكتروني</label>
            <span className="text-xs font-medium" style={{ color: 'var(--muted-foreground)' }}>اختياري</span>
          </div>
          <input
            type="email"
            placeholder="you@email.com"
            dir="ltr"
            disabled={isSubmitting}
            {...register('email')}
            className="input-base text-left font-sans"
          />
        </div>

        {/* Passwords */}
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-1.5">
            <label className="block text-sm font-semibold text-foreground">كلمة المرور</label>
            <input
              type="password"
              placeholder="••••••••"
              dir="ltr"
              disabled={isSubmitting}
              {...register('password')}
              className="input-base text-left tracking-widest"
            />
          </div>
          <div className="space-y-1.5">
            <label className="block text-sm font-semibold text-foreground">تأكيد المرور</label>
            <input
              type="password"
              placeholder="••••••••"
              dir="ltr"
              disabled={isSubmitting}
              {...register('confirmPassword')}
              className="input-base text-left tracking-widest"
            />
          </div>
        </div>

        {errors.password && (
          <p className="text-sm font-medium flex items-center gap-1.5 mt-1" style={{ color: 'var(--destructive)' }}>
            <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: 'var(--destructive)' }} />
            كلمة المرور يجب أن تكون 8 أحرف على الأقل
          </p>
        )}

        {/* Submit */}
        <div className="pt-6">
          <button
            type="submit"
            disabled={isSubmitting}
            className="group w-full relative h-12 btn-primary font-semibold overflow-hidden transition-all shadow-lg hover:shadow-xl hover:scale-[1.01] flex items-center justify-center gap-2"
          >
            {isSubmitting ? (
              <>
                <Loader2 size={18} className="animate-spin" />
                <span>جاري إنشاء الحساب...</span>
              </>
            ) : (
              <>
                <UserPlus size={18} />
                <span>إنشاء الحساب</span>
                <ArrowLeft size={18} className="opacity-0 -ml-4 transition-all group-hover:opacity-100 group-hover:ml-0" />
              </>
            )}
            {!isSubmitting && (
              <div className="absolute inset-0 -translate-x-full group-hover:animate-shimmer" style={{ background: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent)' }} />
            )}
          </button>
        </div>
      </form>

      {/* Footer */}
      <div className="mt-8 text-center pt-6 border-t" style={{ borderColor: 'var(--border)' }}>
        <p className="text-sm font-medium" style={{ color: 'var(--muted-foreground)' }}>
          هل لديك حساب بالفعل؟{' '}
          <Link href="/auth/login" className="hover:underline underline-offset-4 decoration-2" style={{ color: 'var(--primary)' }}>
            تسجيل الدخول
          </Link>
        </p>
      </div>
    </>
  );
}
