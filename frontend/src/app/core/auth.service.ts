import { Injectable, signal } from '@angular/core';
import {
  signUp,
  confirmSignUp,
  signIn,
  confirmSignIn,
  signOut,
  getCurrentUser,
  fetchAuthSession,
  resendSignUpCode,
} from 'aws-amplify/auth';

export interface SignInResult {
  isSignedIn: boolean;
  step:
    | 'DONE'
    | 'CONFIRM_SIGN_UP'
    | 'TOTP_SETUP'
    | 'TOTP_CONFIRM'
    | 'NEW_PASSWORD'
    | 'UNKNOWN';
  totpSetupUri?: string;
  sharedSecret?: string;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  readonly userEmail = signal<string | null>(null);

  async register(email: string, password: string): Promise<void> {
    await signUp({
      username: email,
      password,
      options: { userAttributes: { email } },
    });
  }

  async confirmRegistration(email: string, code: string): Promise<void> {
    await confirmSignUp({ username: email, confirmationCode: code });
  }

  async resendCode(email: string): Promise<void> {
    await resendSignUpCode({ username: email });
  }

  async login(email: string, password: string): Promise<SignInResult> {
    const { isSignedIn, nextStep } = await signIn({ username: email, password });
    return this.mapStep(isSignedIn, nextStep, email);
  }

  // Confirma o codigo TOTP (tanto no setup inicial quanto no login subsequente).
  async confirmTotp(code: string): Promise<SignInResult> {
    const { isSignedIn, nextStep } = await confirmSignIn({ challengeResponse: code });
    return this.mapStep(isSignedIn, nextStep, this.userEmail());
  }

  private mapStep(isSignedIn: boolean, nextStep: any, email: string | null): SignInResult {
    if (email) this.userEmail.set(email);
    const stepName = nextStep?.signInStep;

    if (isSignedIn || stepName === 'DONE') {
      return { isSignedIn: true, step: 'DONE' };
    }
    switch (stepName) {
      case 'CONFIRM_SIGN_IN_WITH_TOTP_CODE':
        return { isSignedIn: false, step: 'TOTP_CONFIRM' };
      case 'CONTINUE_SIGN_IN_WITH_TOTP_SETUP': {
        const uri = nextStep?.totpSetupDetails?.getSetupUri?.('testproject')?.toString();
        const secret = nextStep?.totpSetupDetails?.sharedSecret;
        return { isSignedIn: false, step: 'TOTP_SETUP', totpSetupUri: uri, sharedSecret: secret };
      }
      case 'CONFIRM_SIGN_UP':
        return { isSignedIn: false, step: 'CONFIRM_SIGN_UP' };
      default:
        return { isSignedIn: false, step: 'UNKNOWN' };
    }
  }

  async logout(): Promise<void> {
    await signOut();
    this.userEmail.set(null);
  }

  async isAuthenticated(): Promise<boolean> {
    try {
      await getCurrentUser();
      const session = await fetchAuthSession();
      return !!session.tokens?.idToken;
    } catch {
      return false;
    }
  }

  async getIdToken(): Promise<string | null> {
    try {
      const session = await fetchAuthSession();
      return session.tokens?.idToken?.toString() ?? null;
    } catch {
      return null;
    }
  }

  async loadCurrentUser(): Promise<void> {
    try {
      const user = await getCurrentUser();
      this.userEmail.set(user.signInDetails?.loginId ?? user.username ?? null);
    } catch {
      this.userEmail.set(null);
    }
  }
}
