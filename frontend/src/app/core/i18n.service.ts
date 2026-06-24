import { Injectable, signal } from '@angular/core';

export type Locale = 'pt' | 'en' | 'es';

const STORAGE_KEY = 'testproject.locale';
const SUPPORTED: Locale[] = ['pt', 'en', 'es'];

@Injectable({ providedIn: 'root' })
export class I18nService {
  readonly locale = signal<Locale>('pt');
  private messages = signal<Record<string, string>>({});

  async init(): Promise<void> {
    const saved = localStorage.getItem(STORAGE_KEY) as Locale | null;
    const locale = saved && SUPPORTED.includes(saved) ? saved : 'pt';
    await this.setLocale(locale);
  }

  async setLocale(locale: Locale): Promise<void> {
    const res = await fetch(`i18n/${locale}.json`, { cache: 'no-store' });
    if (!res.ok) {
      throw new Error(`Failed to load i18n/${locale}.json`);
    }
    this.messages.set((await res.json()) as Record<string, string>);
    this.locale.set(locale);
    localStorage.setItem(STORAGE_KEY, locale);
    document.documentElement.lang = locale;
  }

  t(key: string, params?: Record<string, string | number>): string {
    let text = this.messages()[key] ?? key;
    if (params) {
      for (const [name, value] of Object.entries(params)) {
        text = text.replaceAll(`{${name}}`, String(value));
      }
    }
    return text;
  }
}
