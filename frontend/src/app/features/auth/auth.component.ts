import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../core/auth.service';
import { ConfigService } from '../../core/app-config';

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
  imports: [FormsModule],
  templateUrl: './auth.component.html',
  styleUrl: './auth.component.scss',
})
export class AuthComponent {
  private auth = inject(AuthService);
  private router = inject(Router);
  private config = inject(ConfigService);

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

  // QR code via servico publico (somente leitura do segredo otpauth).
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

  private fail(e: unknown, fallback = 'Ocorreu um erro. Tente novamente.') {
    this.errorMsg.set(this.auth.mapAuthError(e) || fallback);
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
      this.infoMsg.set('Enviamos um código de verificação para seu email.');
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
      this.infoMsg.set('Conta confirmada! Faça login para configurar o MFA.');
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
      this.infoMsg.set('Novo código enviado.');
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
      this.infoMsg.set(
        'Se o email estiver cadastrado, enviaremos um código de verificação em instantes.',
      );
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
      this.infoMsg.set('Novo código enviado, se o email estiver cadastrado.');
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
      this.errorMsg.set('As senhas informadas não coincidem.');
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
        this.infoMsg.set('Confirme seu email para continuar.');
        this.setMode('confirm');
        break;
      default:
        this.errorMsg.set('Não foi possível concluir o login.');
    }
  }
}
