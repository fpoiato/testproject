import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../core/auth.service';
import { ConfigService } from '../../core/app-config';
import { I18nService } from '../../core/i18n.service';
import { TranslatePipe } from '../../core/translate.pipe';
import { LanguageSelectorComponent } from '../../shared/language-selector.component';

type Mode =
  | 'login'
  | 'register'
  | 'confirm'
  | 'totp-setup'
  | 'totp-confirm'
  | 'forgot-request'
  | 'forgot-confirm'
  | 'forgot-success';

@Component({
  selector: 'app-auth',
  imports: [FormsModule, TranslatePipe, LanguageSelectorComponent],
  templateUrl: './auth.component.html',
  styleUrl: './auth.component.scss',
})
export class AuthComponent {
  private auth = inject(AuthService);
  private router = inject(Router);
  private config = inject(ConfigService);
  private i18n = inject(I18nService);

  mode = signal<Mode>('login');
  loading = signal(false);
  errorMsg = signal<string | null>(null);
  infoMsg = signal<string | null>(null);

  email = '';
  password = '';
  newPassword = '';
  confirmPassword = '';
  code = '';

  totpUri = signal<string | null>(null);
  totpSecret = signal<string | null>(null);

  environment = this.config.environment;

  qrUrl(): string {
    const uri = this.totpUri();
    if (!uri) return '';
    return `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(uri)}`;
  }

  setMode(m: Mode) {
    this.mode.set(m);
    this.errorMsg.set(null);
    this.infoMsg.set(null);
  }

  private fail(e: unknown, fallbackKey = 'error.generic') {
    this.errorMsg.set(this.auth.mapAuthError(e) || this.i18n.t(fallbackKey));
  }

  async doLogin() {
    this.loading.set(true);
    this.errorMsg.set(null);
    try {
      const res = await this.auth.login(this.email, this.password);
      this.handleResult(res);
    } catch (e) {
      this.fail(e);
    } finally {
      this.loading.set(false);
    }
  }

  async doRegister() {
    this.loading.set(true);
    this.errorMsg.set(null);
    try {
      await this.auth.register(this.email, this.password);
      this.infoMsg.set(this.i18n.t('auth.info.verificationSent'));
      this.setMode('confirm');
    } catch (e) {
      this.fail(e);
    } finally {
      this.loading.set(false);
    }
  }

  async doConfirm() {
    this.loading.set(true);
    this.errorMsg.set(null);
    try {
      await this.auth.confirmRegistration(this.email, this.code);
      this.infoMsg.set(this.i18n.t('auth.info.accountConfirmed'));
      this.code = '';
      this.setMode('login');
    } catch (e) {
      this.fail(e);
    } finally {
      this.loading.set(false);
    }
  }

  async resend() {
    try {
      await this.auth.resendCode(this.email);
      this.infoMsg.set(this.i18n.t('auth.info.codeResent'));
    } catch (e) {
      this.fail(e);
    }
  }

  async requestPasswordReset() {
    this.loading.set(true);
    this.errorMsg.set(null);
    this.infoMsg.set(null);
    try {
      await this.auth.requestPasswordReset(this.email);
      this.infoMsg.set(this.i18n.t('auth.info.resetCodeSent'));
      this.code = '';
      this.newPassword = '';
      this.confirmPassword = '';
      this.setMode('forgot-confirm');
    } catch (e) {
      this.fail(e);
    } finally {
      this.loading.set(false);
    }
  }

  async resendPasswordReset() {
    this.loading.set(true);
    this.errorMsg.set(null);
    try {
      await this.auth.requestPasswordReset(this.email);
      this.infoMsg.set(this.i18n.t('auth.info.resetCodeResent'));
    } catch (e) {
      this.fail(e);
    } finally {
      this.loading.set(false);
    }
  }

  async confirmPasswordReset() {
    const validationError = this.auth.validatePassword(this.newPassword, this.environment);
    if (validationError) {
      this.errorMsg.set(validationError);
      return;
    }
    if (this.newPassword !== this.confirmPassword) {
      this.errorMsg.set(this.i18n.t('error.passwordMismatch'));
      return;
    }

    this.loading.set(true);
    this.errorMsg.set(null);
    try {
      await this.auth.confirmPasswordReset(this.email, this.code, this.newPassword);
      this.password = '';
      this.code = '';
      this.newPassword = '';
      this.confirmPassword = '';
      this.infoMsg.set(null);
      this.setMode('forgot-success');
    } catch (e) {
      this.fail(e);
    } finally {
      this.loading.set(false);
    }
  }

  backToLogin() {
    this.password = '';
    this.code = '';
    this.newPassword = '';
    this.confirmPassword = '';
    this.setMode('login');
  }

  async confirmTotp() {
    this.loading.set(true);
    this.errorMsg.set(null);
    try {
      const res = await this.auth.confirmTotp(this.code);
      this.code = '';
      this.handleResult(res);
    } catch (e) {
      this.fail(e);
    } finally {
      this.loading.set(false);
    }
  }

  private handleResult(res: { isSignedIn: boolean; step: string; totpSetupUri?: string; sharedSecret?: string }) {
    if (res.isSignedIn || res.step === 'DONE') {
      this.router.navigate(['/veiculos']);
      return;
    }
    switch (res.step) {
      case 'TOTP_SETUP':
        this.totpUri.set(res.totpSetupUri ?? null);
        this.totpSecret.set(res.sharedSecret ?? null);
        this.setMode('totp-setup');
        break;
      case 'TOTP_CONFIRM':
        this.setMode('totp-confirm');
        break;
      case 'CONFIRM_SIGN_UP':
        this.infoMsg.set(this.i18n.t('auth.info.confirmEmail'));
        this.setMode('confirm');
        break;
      default:
        this.errorMsg.set(this.i18n.t('error.loginFailed'));
    }
  }
}
