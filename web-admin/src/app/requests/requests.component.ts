import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';

@Component({
  selector: 'app-requests',
  templateUrl: './requests.component.html',
  styleUrls: ['./requests.component.css']
})
export class RequestsComponent implements OnInit {
  allRequests: any[] = [];
  filteredRequests: any[] = [];
  currentFilter: string = 'all';
  isLoading: boolean = false;

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    this.loadRequests();
  }

  loadRequests(): void {
    this.isLoading = true;
    this.apiService.getRequests().subscribe({
      next: (response) => {
        if (response?.requests) {
          this.allRequests = response.requests;
          this.applyFilter(this.currentFilter);
        }
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Erro ao buscar solicitações:', err);
        this.isLoading = false;
      }
    });
  }

  applyFilter(filter: string): void {
    this.currentFilter = filter;
    if (filter === 'all') {
      this.filteredRequests = this.allRequests;
    } else {
      this.filteredRequests = this.allRequests.filter(r => r.status === filter);
    }
  }

  getStatusBadgeClass(status: string): string {
    switch (status) {
      case 'pending': return 'badge-pending';
      case 'assigned':
      case 'on_the_way':
      case 'arrived':
      case 'in_progress': return 'badge-assigned';
      case 'completed': return 'badge-completed';
      case 'canceled': return 'badge-canceled';
      default: return '';
    }
  }

  getStatusLabel(status: string): string {
    const map: { [key: string]: string } = {
      'pending': 'Aguardando Aceite',
      'assigned': 'Aceito / Atribuído',
      'on_the_way': 'Técnico Em Deslocamento',
      'arrived': 'Técnico no Local',
      'in_progress': 'Em Andamento',
      'completed': 'Concluído',
      'canceled': 'Cancelado'
    };
    return map[status] || status;
  }
}


