import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../core/auth.service';
import { ConfigService } from '../../core/app-config';

type Mode = 'login' | 'register' | 'confirm' | 'totp-setup' | 'totp-confirm';

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

  private fail(e: any) {
    this.errorMsg.set(e?.message || 'Ocorreu um erro. Tente novamente.');
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
