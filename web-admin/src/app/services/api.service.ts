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

  // --- ÁREA DO PROFISSIONAL ---
  getCategories(): Observable<any> {
    return this.http.get(`${this.apiUrl}/pro-catalog/categories`);
  }

  updateProCategories(proId: number, operationArea: string): Observable<any> {
    return this.http.put(`${this.apiUrl}/pro-catalog/${proId}/categories`, { operation_area: operationArea });
  }

  getProServices(proId: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/pro-catalog/${proId}/services`);
  }

  createProService(proId: number, data: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/pro-catalog/${proId}/services`, data);
  }

  updateProService(proId: number, serviceId: number, data: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/pro-catalog/${proId}/services/${serviceId}`, data);
  }

  deleteProService(proId: number, serviceId: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/pro-catalog/${proId}/services/${serviceId}`);
  }

  getProProducts(proId: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/pro-catalog/${proId}/products`);
  }

  createProProduct(proId: number, data: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/pro-catalog/${proId}/products`, data);
  }

  updateProProduct(proId: number, productId: number, data: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/pro-catalog/${proId}/products/${productId}`, data);
  }

  deleteProProduct(proId: number, productId: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/pro-catalog/${proId}/products/${productId}`);
  }

  seedProDefaults(proId: number, categoryId: number): Observable<any> {
    return this.http.post(`${this.apiUrl}/pro-catalog/${proId}/seed`, { categoryId });
  }
}


