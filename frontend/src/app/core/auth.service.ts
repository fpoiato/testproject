import { Injectable, inject, signal } from '@angular/core';
import {
  signUp,
  confirmSignUp,
  signIn,
  confirmSignIn,
  signOut,
  getCurrentUser,
  fetchAuthSession,
  resendSignUpCode,
  resetPassword,
  confirmResetPassword,
} from 'aws-amplify/auth';
import { I18nService } from './i18n.service';

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
  private i18n = inject(I18nService);
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

  async requestPasswordReset(email: string): Promise<void> {
    await resetPassword({ username: email });
  }

  async confirmPasswordReset(email: string, code: string, newPassword: string): Promise<void> {
    await confirmResetPassword({
      username: email,
      confirmationCode: code,
      newPassword,
    });
  }

  validatePassword(password: string, environment: string): string | null {
    const minLength = environment === 'development' ? 8 : 12;
    if (password.length < minLength) {
      return this.i18n.t('error.passwordMinLength', { min: minLength });
    }
    if (!/[a-z]/.test(password)) {
      return this.i18n.t('error.passwordLowercase');
    }
    if (!/[A-Z]/.test(password)) {
      return this.i18n.t('error.passwordUppercase');
    }
    if (!/[0-9]/.test(password)) {
      return this.i18n.t('error.passwordNumber');
    }
    if (environment !== 'development' && !/[^A-Za-z0-9]/.test(password)) {
      return this.i18n.t('error.passwordSpecial');
    }
    return null;
  }

  mapAuthError(error: unknown): string {
    const name = (error as { name?: string })?.name;
    switch (name) {
      case 'InvalidParameterException':
        return this.i18n.t('error.invalidEmail');
      case 'CodeMismatchException':
        return this.i18n.t('error.codeMismatch');
      case 'ExpiredCodeException':
        return this.i18n.t('error.codeExpired');
      case 'InvalidPasswordException':
        return this.i18n.t('error.invalidPassword');
      case 'LimitExceededException':
        return this.i18n.t('error.limitExceeded');
      case 'NotAuthorizedException':
        return this.i18n.t('error.notAuthorized');
      case 'UserNotConfirmedException':
        return this.i18n.t('error.userNotConfirmed');
      case 'UsernameExistsException':
        return this.i18n.t('error.usernameExists');
      default:
        return (error as { message?: string })?.message || this.i18n.t('error.operationFailed');
    }
  }

  async login(email: string, password: string): Promise<SignInResult> {
    const { isSignedIn, nextStep } = await signIn({ username: email, password });
    return this.mapStep(isSignedIn, nextStep, email);
  }

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
