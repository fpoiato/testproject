import { Routes } from '@angular/router';
import { authGuard } from './core/auth.guard';

export const routes: Routes = [
  {
    path: 'login',
    loadComponent: () =>
      import('./features/auth/auth.component').then((m) => m.AuthComponent),
  },
  {
    path: 'veiculos',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./features/veiculos/veiculos.component').then(
        (m) => m.VeiculosComponent
      ),
  },
  { path: '', pathMatch: 'full', redirectTo: 'veiculos' },
  { path: '**', redirectTo: 'veiculos' },
];
