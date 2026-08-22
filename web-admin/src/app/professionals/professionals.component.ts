import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';

@Component({
  selector: 'app-professionals',
  templateUrl: './professionals.component.html',
  styleUrls: ['./professionals.component.css']
})
export class ProfessionalsComponent implements OnInit {
  allProfessionals: any[] = [];
  filteredProfessionals: any[] = [];
  currentFilter: string = 'all';
  isLoading: boolean = false;
  selectedProfessional: any = null;

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    this.loadProfessionals();
  }

  loadProfessionals(): void {
    this.isLoading = true;
    this.apiService.getProfessionals().subscribe({
      next: (response) => {
        if (response?.users) {
          this.allProfessionals = response.users.filter((user: any) => user.role?.toLowerCase() === 'professional');
          this.applyFilter(this.currentFilter);

          if (this.selectedProfessional) {
            const updated = this.allProfessionals.find(p => p.id === this.selectedProfessional.id);
            if (updated) this.selectedProfessional = updated;
          }
        }
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Erro ao listar profissionais:', err);
        this.isLoading = false;
      }
    });
  }

  applyFilter(filter: string): void {
    this.currentFilter = filter;
    if (filter === 'all') {
      this.filteredProfessionals = this.allProfessionals;
    } else {
      this.filteredProfessionals = this.allProfessionals.filter(p => p.status?.toLowerCase() === filter.toLowerCase());
    }
  }

  openDetails(pro: any): void {
    this.selectedProfessional = pro;
  }

  closeDetails(): void {
    this.selectedProfessional = null;
  }

  changeStatus(userId: number, newStatus: string): void {
    this.apiService.updateUserStatus(userId, newStatus).subscribe({
      next: () => {
        if (this.selectedProfessional && this.selectedProfessional.id === userId) {
          this.selectedProfessional.status = newStatus;
        }
        this.loadProfessionals();
      },
      error: (err) => {
        console.error('Erro ao atualizar status:', err);
      }
    });
  }

  getStatusBadgeClass(status: string): string {
    switch (status) {
      case 'active': return 'badge-active';
      case 'pending': return 'badge-pending';
      case 'blocked': return 'badge-blocked';
      default: return '';
    }
  }

  getStatusLabel(status: string): string {
    switch (status) {
      case 'active': return 'Ativo / Aprovado';
      case 'pending': return 'Aguardando Aprovação';
      case 'blocked': return 'Bloqueado';
      default: return status;
    }
  }
}


