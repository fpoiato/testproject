import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { ConfigService } from './app-config';
import { Veiculo } from './veiculo.model';

interface ApiResponse<T> {
  success: boolean;
  data: T;
  count?: number;
}

@Injectable({ providedIn: 'root' })
export class VeiculoService {
  private http = inject(HttpClient);
  private config = inject(ConfigService);

  private base(): string {
    return `${this.config.apiUrl}/veiculos`;
  }

  list(): Observable<Veiculo[]> {
    return this.http
      .get<ApiResponse<Veiculo[]>>(this.base())
      .pipe(map((r) => r.data ?? []));
  }

  create(veiculo: Veiculo): Observable<Veiculo> {
    return this.http
      .post<ApiResponse<Veiculo>>(this.base(), veiculo)
      .pipe(map((r) => r.data));
  }

  update(id: string, veiculo: Partial<Veiculo>): Observable<Veiculo> {
    return this.http
      .put<ApiResponse<Veiculo>>(`${this.base()}/${id}`, veiculo)
      .pipe(map((r) => r.data));
  }

  remove(id: string): Observable<void> {
    return this.http
      .delete<ApiResponse<void>>(`${this.base()}/${id}`)
      .pipe(map(() => void 0));
  }
}
