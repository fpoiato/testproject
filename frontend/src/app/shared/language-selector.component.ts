import { Component, inject, input } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { I18nService, Locale } from '../core/i18n.service';
import { TranslatePipe } from '../core/translate.pipe';

@Component({
  selector: 'app-language-selector',
  imports: [FormsModule, TranslatePipe],
  host: {
    '[class.dark]': 'dark()',
  },
  template: `
    <label class="lang-select">
      <span class="lang-label">{{ 'lang.label' | t }}</span>
      <select [ngModel]="i18n.locale()" (ngModelChange)="onChange($event)">
        <option value="pt">{{ 'lang.pt' | t }}</option>
        <option value="en">{{ 'lang.en' | t }}</option>
        <option value="es">{{ 'lang.es' | t }}</option>
      </select>
    </label>
  `,
  styles: `
    .lang-select {
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      font-size: 0.85rem;
    }
    .lang-label {
      opacity: 0.85;
    }
    select {
      border: 1px solid #cbd5e1;
      border-radius: 6px;
      background: #fff;
      color: #0f172a;
      padding: 0.2rem 0.35rem;
    }
    :host(.dark) select {
      border-color: rgba(255, 255, 255, 0.35);
      background: rgba(0, 0, 0, 0.2);
      color: #fff;
    }
  `,
})
export class LanguageSelectorComponent {
  dark = input(false);
  i18n = inject(I18nService);

  onChange(locale: Locale) {
    void this.i18n.setLocale(locale);
  }
}
