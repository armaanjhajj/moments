import type { NextAuthOptions } from 'next-auth';
import EmailProvider from 'next-auth/providers/email';
import { PrismaAdapter } from '@auth/prisma-adapter';
import { prisma } from '@/lib/db';
import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_SERVER_HOST,
  port: Number(process.env.EMAIL_SERVER_PORT || 587),
  auth: {
    user: process.env.EMAIL_SERVER_USER,
    pass: process.env.EMAIL_SERVER_PASSWORD,
  },
});

export const authOptions: NextAuthOptions = {
  adapter: PrismaAdapter(prisma),
  session: { strategy: 'jwt' },
  providers: [
    EmailProvider({
      from: process.env.EMAIL_FROM,
      sendVerificationRequest: async ({ identifier, url }) => {
        await transporter.sendMail({
          to: identifier,
          from: process.env.EMAIL_FROM,
          subject: 'Your sign-in link for Moments',
          text: `Sign in to Moments: ${url}`,
          html: `<p>Sign in to Moments:</p><p><a href="${url}">${url}</a></p>`,
        });
      },
    }),
  ],
  secret: process.env.AUTH_SECRET,
};
