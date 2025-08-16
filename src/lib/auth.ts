import type { NextAuthOptions } from 'next-auth';
import EmailProvider from 'next-auth/providers/email';
import { PrismaAdapter } from '@auth/prisma-adapter';
import { prisma } from '@/lib/db';
import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

export const authOptions: NextAuthOptions = {
  adapter: PrismaAdapter(prisma),
  session: { strategy: 'jwt' },
  providers: [
    EmailProvider({
      from: process.env.EMAIL_FROM,
      sendVerificationRequest: async ({ identifier, url }) => {
        await resend.emails.send({
          to: identifier,
          from: process.env.EMAIL_FROM || 'no-reply@makemoments.app',
          subject: 'Your sign-in link for Moments',
          text: `Sign in to Moments: ${url}`,
          html: `<p>Sign in to Moments:</p><p><a href="${url}">${url}</a></p>`,
        });
      },
    }),
  ],
  secret: process.env.AUTH_SECRET,
};
