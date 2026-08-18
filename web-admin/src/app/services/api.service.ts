import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private readonly apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  getDashboardStats(): Observable<any> {
    return this.http.get(`${this.apiUrl}/admin/stats`);
  }

  getRequests(): Observable<any> {
    return this.http.get(`${this.apiUrl}/services/requests`);
  }

  getProfessionals(): Observable<any> {
    return this.http.get(`${this.apiUrl}/users`);
  }

  getPendingProfessionals(): Observable<any> {
    return this.http.get(`${this.apiUrl}/admin/professionals/pending`);
  }

  updateUserStatus(userId: number, status: string): Observable<any> {
    return this.http.put(`${this.apiUrl}/admin/users/${userId}/status`, { status });
  }

  confirmPayment(requestId: number): Observable<any> {
    return this.http.post(`${this.apiUrl}/admin/requests/${requestId}/confirm-payment`, {});
  }
}

