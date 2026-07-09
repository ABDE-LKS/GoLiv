'use client';

import { useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import Link from 'next/link';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useAuthStore } from '@/stores/authStore';
import { authService } from '@/lib/services/authService';
import { AlertCircle, Loader2, LogIn, ArrowLeft } from 'lucide-react';

const loginSchema = z.object({
  phone: z.string().min(8, 'Invalid phone number'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
});

type LoginFormData = z.infer<typeof loginSchema>;

export default function LoginPage() {
  const router = useRouter();
  const params = useParams();
  const locale = (params?.locale as string) || 'ar';
  const { setAuth, setError, error } = useAuthStore();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    setIsSubmitting(true);
    try {
      const response = await authService.login(data.phone, data.password);

      // 1. Update Zustand store (in-memory)
      setAuth(response);

      // 2. Write DIRECTLY to localStorage (guaranteed synchronous)
      //    This ensures data is there before the next page loads,
      //    regardless of Zustand persist internal timing
      localStorage.setItem('goliv-auth', JSON.stringify({
        state: {
          user: response.user,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken ?? null,
        },
        version: 0,
      }));

      // 3. Full page reload so dashboard reads fresh from localStorage
      window.location.href = `/${locale}/dashboard`;

    } catch (err: any) {
      const message = err.response?.data?.message || 'فشل تسجيل الدخول. يرجى التحقق من بياناتك.';
      setError(message);
    } finally {
      setIsSubmitting(false);
    }
  };


  return (
    <>
      <div className="mb-8 text-center pt-2">
        <h1 className="heading-1 text-foreground mb-2">مرحباً بك مجدداً</h1>
        <p className="subtitle">
          قم بتسجيل الدخول للوصول إلى حسابك ومتابعة أعمالك
        </p>
      </div>

      {error && (
        <div className="mb-6 p-4 rounded-xl flex gap-3 overflow-hidden shadow-sm items-center" style={{ backgroundColor: 'color-mix(in srgb, var(--destructive) 10%, transparent)', border: '1px solid color-mix(in srgb, var(--destructive) 30%, transparent)' }}>
          <AlertCircle style={{ color: 'var(--destructive)' }} size={20} />
          <p className="text-sm font-medium" style={{ color: 'var(--destructive)' }}>{error}</p>
        </div>
      )}

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
        {/* Phone Input */}
        <div className="space-y-2">
          <label className="block text-sm font-semibold text-foreground">رقم الهاتف</label>
          <div className="relative group">
            <input
              type="tel"
              disabled={isSubmitting}
              placeholder="0555555555"
              dir="ltr"
              {...register('phone')}
              className="input-base pr-12 w-full text-left font-sans tracking-wide"
            />
            {/* Algerian Flag Prefix Visual */}
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

        {/* Password Input */}
        <div className="space-y-2 pt-1">
          <div className="flex items-center justify-between">
            <label className="block text-sm font-semibold text-foreground">كلمة المرور</label>
            <Link 
              href="/auth/forgot-password" 
              className="text-xs font-semibold hover:opacity-80 transition-opacity"
              style={{ color: 'var(--primary)' }}
            >
              نسيت كلمة المرور؟
            </Link>
          </div>
          <input
            type="password"
            disabled={isSubmitting}
            placeholder="••••••••"
            dir="ltr"
            {...register('password')}
            className="input-base w-full text-left tracking-widest"
          />
          {errors.password && (
            <p className="text-sm font-medium flex items-center gap-1.5 mt-1" style={{ color: 'var(--destructive)' }}>
              <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: 'var(--destructive)' }} />
              كلمة المرور قصيرة جداً
            </p>
          )}
        </div>

        {/* Submit Button */}
        <div className="pt-6">
          <button
            type="submit"
            disabled={isSubmitting}
            className="group w-full relative h-12 btn-primary font-semibold overflow-hidden transition-all shadow-lg hover:shadow-xl hover:scale-[1.01] flex items-center justify-center gap-2"
          >
            {isSubmitting ? (
              <>
                <Loader2 size={18} className="animate-spin" />
                <span>جاري الدخول...</span>
              </>
            ) : (
              <>
                <span>تسجيل الدخول</span>
                <ArrowLeft size={18} className="transition-transform group-hover:-translate-x-1" />
              </>
            )}
            
            {/* Shimmer effect inside global CSS */}
            {!isSubmitting && (
              <div className="absolute inset-0 -translate-x-full group-hover:animate-shimmer" style={{ background: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent)' }} />
            )}
          </button>
        </div>
      </form>

      {/* Footer */}
      <div className="mt-8 text-center pt-6 border-t" style={{ borderColor: 'var(--border)' }}>
        <p className="text-sm font-medium" style={{ color: 'var(--muted-foreground)' }}>
          جديد في GoLiv ؟{' '}
          <Link href="/auth/register" className="hover:underline underline-offset-4 decoration-2" style={{ color: 'var(--primary)' }}>
            إنشاء حساب جديد
          </Link>
        </p>
      </div>
    </>
  );
}
