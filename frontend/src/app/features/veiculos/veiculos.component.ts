import { Component, computed, inject, signal, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import * as XLSX from 'xlsx';
import { VeiculoService } from '../../core/veiculo.service';
import { Veiculo } from '../../core/veiculo.model';
import { I18nService } from '../../core/i18n.service';
import { TranslatePipe } from '../../core/translate.pipe';

type SortKey = keyof Pick<Veiculo, 'placa' | 'marca' | 'modelo' | 'versao' | 'cor' | 'ano'>;

@Component({
  selector: 'app-veiculos',
  imports: [FormsModule, TranslatePipe],
  templateUrl: './veiculos.component.html',
  styleUrl: './veiculos.component.scss',
})
export class VeiculosComponent implements OnInit {
  private service = inject(VeiculoService);
  private i18n = inject(I18nService);

  veiculos = signal<Veiculo[]>([]);
  loading = signal(false);
  errorMsg = signal<string | null>(null);

  search = signal('');
  marcaFilter = signal('');
  sortKey = signal<SortKey>('marca');
  sortAsc = signal(true);

  showForm = signal(false);
  editing = signal<Veiculo | null>(null);
  form: Veiculo = this.emptyForm();
  saving = signal(false);

  marcas = computed(() => {
    const set = new Set(this.veiculos().map((v) => v.marca).filter(Boolean));
    return Array.from(set).sort();
  });

  filtered = computed(() => {
    const term = this.search().trim().toLowerCase();
    const marca = this.marcaFilter();
    let rows = this.veiculos().filter((v) => {
      const matchesMarca = !marca || v.marca === marca;
      const matchesTerm =
        !term ||
        [v.placa, v.marca, v.modelo, v.versao, v.cor, String(v.ano)]
          .filter(Boolean)
          .some((field) => String(field).toLowerCase().includes(term));
      return matchesMarca && matchesTerm;
    });

    const key = this.sortKey();
    const dir = this.sortAsc() ? 1 : -1;
    rows = [...rows].sort((a, b) => {
      const av = a[key] ?? '';
      const bv = b[key] ?? '';
      if (av < bv) return -1 * dir;
      if (av > bv) return 1 * dir;
      return 0;
    });
    return rows;
  });

  ngOnInit() {
    this.load();
  }

  load() {
    this.loading.set(true);
    this.errorMsg.set(null);
    this.service.list().subscribe({
      next: (data) => {
        this.veiculos.set(data);
        this.loading.set(false);
      },
      error: (e) => {
        this.errorMsg.set(e?.error?.error || e?.message || this.i18n.t('error.loadVehicles'));
        this.loading.set(false);
      },
    });
  }

  toggleSort(key: SortKey) {
    if (this.sortKey() === key) {
      this.sortAsc.set(!this.sortAsc());
    } else {
      this.sortKey.set(key);
      this.sortAsc.set(true);
    }
  }

  sortIndicator(key: SortKey): string {
    if (this.sortKey() !== key) return '';
    return this.sortAsc() ? '▲' : '▼';
  }

  private emptyForm(): Veiculo {
    return { placa: '', marca: '', modelo: '', versao: '', cor: '', ano: new Date().getFullYear() };
  }

  openCreate() {
    this.editing.set(null);
    this.form = this.emptyForm();
    this.showForm.set(true);
  }

  openEdit(v: Veiculo) {
    this.editing.set(v);
    this.form = { ...v };
    this.showForm.set(true);
  }

  closeForm() {
    this.showForm.set(false);
    this.errorMsg.set(null);
  }

  save() {
    this.saving.set(true);
    this.errorMsg.set(null);
    const payload: Veiculo = {
      placa: this.form.placa,
      marca: this.form.marca,
      modelo: this.form.modelo,
      versao: this.form.versao,
      cor: this.form.cor,
      ano: Number(this.form.ano),
    };
    const editing = this.editing();
    const op = editing?.id
      ? this.service.update(editing.id, payload)
      : this.service.create(payload);

    op.subscribe({
      next: () => {
        this.saving.set(false);
        this.showForm.set(false);
        this.load();
      },
      error: (e) => {
        this.saving.set(false);
        const details = e?.error?.details;
        this.errorMsg.set(
          (Array.isArray(details) ? details.join('; ') : null) ||
            e?.error?.error ||
            this.i18n.t('error.save'),
        );
      },
    });
  }

  remove(v: Veiculo) {
    if (!v.id) return;
    if (!confirm(this.i18n.t('veiculos.confirmDelete', { brand: v.marca, model: v.modelo }))) return;
    this.service.remove(v.id).subscribe({
      next: () => this.load(),
      error: (e) => this.errorMsg.set(e?.error?.error || this.i18n.t('error.delete')),
    });
  }

  exportExcel() {
    const rows = this.filtered().map((v) => ({
      [this.i18n.t('veiculos.col.plate')]: v.placa,
      [this.i18n.t('veiculos.col.brand')]: v.marca,
      [this.i18n.t('veiculos.col.model')]: v.modelo,
      [this.i18n.t('veiculos.col.version')]: v.versao ?? '',
      [this.i18n.t('veiculos.col.color')]: v.cor,
      [this.i18n.t('veiculos.col.year')]: v.ano,
    }));
    const ws = XLSX.utils.json_to_sheet(rows);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, this.i18n.t('veiculos.sheetName'));
    XLSX.writeFile(wb, `veiculos-${new Date().toISOString().slice(0, 10)}.xlsx`);
  }
}
