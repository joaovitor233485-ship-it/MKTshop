import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { DashboardComponent } from './dashboard/dashboard.component';
import { ProfessionalsComponent } from './professionals/professionals.component';
import { RequestsComponent } from './requests/requests.component';
import { ProPortalComponent } from './pro-portal/pro-portal.component';

const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'professionals', component: ProfessionalsComponent },
  { path: 'requests', component: RequestsComponent },
  { path: 'pro-portal', component: ProPortalComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
