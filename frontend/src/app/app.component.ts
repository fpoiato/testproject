import { Component, inject, signal } from '@angular/core';
import { RouterOutlet, Router } from '@angular/router';
import { ConfigService } from './core/app-config';
import { AuthService } from './core/auth.service';
import { TranslatePipe } from './core/translate.pipe';
import { LanguageSelectorComponent } from './shared/language-selector.component';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, TranslatePipe, LanguageSelectorComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
})
export class AppComponent {
  private config = inject(ConfigService);
  private router = inject(Router);
  auth = inject(AuthService);

  environment = signal(this.config.environment);

  envClass(): string {
    return `env-${this.environment()}`;
  }

  async logout() {
    await this.auth.logout();
    this.router.navigate(['/login']);
  }
}
