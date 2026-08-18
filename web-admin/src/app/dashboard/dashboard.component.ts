import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {
  stats: any = {
    total_clients: 0,
    active_pros: 0,
    pending_pros: 0,
    active_requests: 0,
    completed_requests: 0,
    total_revenue: 0.00
  };
  isLoading: boolean = true;

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    this.loadStats();
  }

  loadStats(): void {
    this.isLoading = true;
    this.apiService.getDashboardStats().subscribe({
      next: (res) => {
        if (res?.stats) {
          this.stats = res.stats;
        }
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Erro ao buscar métricas:', err);
        this.isLoading = false;
      }
    });
  }
}

