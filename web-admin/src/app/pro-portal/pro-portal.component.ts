import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';

@Component({
  selector: 'app-pro-portal',
  templateUrl: './pro-portal.component.html',
  styleUrls: ['./pro-portal.component.css']
})
export class ProPortalComponent implements OnInit {
  // Profissional selecionado
  selectedProId: number = 2;
  professionals: any[] = [];
  selectedPro: any = null;

  // Categorias do sistema
  categories: any[] = [];
  selectedCategories: number[] = [1, 2]; // Padrão: Celular e Computador

  // Aba ativa: 'services' | 'products' | 'profile'
  activeTab: 'services' | 'products' | 'profile' = 'services';

  // Listas de serviços e produtos
  services: any[] = [];
  products: any[] = [];

  // Filtro de busca
  searchQuery: string = '';

  // Controle de Modais
  showServiceModal: boolean = false;
  editingService: any = null;
  serviceForm: any = {
    category_id: 1,
    name: '',
    description: '',
    price: 0,
    estimated_time: '1 hora',
    status: 'active'
  };

  showProductModal: boolean = false;
  editingProduct: any = null;
  productForm: any = {
    category_id: 1,
    name: '',
    description: '',
    price: 0,
    stock: 1,
    brand: '',
    compatible_model: '',
    status: 'active'
  };

  loading: boolean = false;
  alertMessage: { text: string; type: 'success' | 'error' } | null = null;

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    this.loadCategories();
    this.loadProfessionals();
  }

  showAlert(text: string, type: 'success' | 'error' = 'success'): void {
    this.alertMessage = { text, type };
    setTimeout(() => {
      this.alertMessage = null;
    }, 4000);
  }

  loadCategories(): void {
    this.apiService.getCategories().subscribe({
      next: (res) => {
        if (res.categories) {
          this.categories = res.categories;
        }
      },
      error: (err) => console.error('Erro ao carregar categorias', err)
    });
  }

  loadProfessionals(): void {
    this.apiService.getProfessionals().subscribe({
      next: (res) => {
        if (res.users) {
          this.professionals = res.users.filter((u: any) => u.role === 'professional');
          if (this.professionals.length > 0) {
            const found = this.professionals.find(p => p.id === this.selectedProId);
            this.selectedPro = found || this.professionals[0];
            this.selectedProId = this.selectedPro.id;
          } else {
            // Fallback mock pro
            this.selectedPro = {
              id: 2,
              name: 'Carlos Técnico',
              email: 'pro@shopmkt.com',
              phone: '(11) 98888-2222',
              operation_area: 'Técnico de celular, Técnico de computador/notebook'
            };
          }
          this.loadProCatalog();
        }
      },
      error: () => {
        this.selectedPro = {
          id: 2,
          name: 'Carlos Técnico',
          email: 'pro@shopmkt.com',
          phone: '(11) 98888-2222',
          operation_area: 'Técnico de celular, Técnico de computador/notebook'
        };
        this.loadProCatalog();
      }
    });
  }

  onProChange(proId: number): void {
    this.selectedProId = Number(proId);
    this.selectedPro = this.professionals.find(p => p.id === this.selectedProId) || {
      id: this.selectedProId,
      name: `Profissional #${this.selectedProId}`,
      operation_area: 'Manutenção Geral'
    };
    this.loadProCatalog();
  }

  loadProCatalog(): void {
    this.loading = true;
    this.loadServices();
    this.loadProducts();
  }

  loadServices(): void {
    this.apiService.getProServices(this.selectedProId).subscribe({
      next: (res) => {
        this.services = res.services || [];
        this.loading = false;
      },
      error: (err) => {
        console.error(err);
        this.loading = false;
      }
    });
  }

  loadProducts(): void {
    this.apiService.getProProducts(this.selectedProId).subscribe({
      next: (res) => {
        this.products = res.products || [];
      },
      error: (err) => console.error(err)
    });
  }

  // --- SERVIÇOS ---
  openNewServiceModal(): void {
    this.editingService = null;
    this.serviceForm = {
      category_id: this.categories.length > 0 ? this.categories[0].id : 1,
      name: '',
      description: '',
      price: 100,
      estimated_time: '1 hora',
      status: 'active'
    };
    this.showServiceModal = true;
  }

  openEditServiceModal(service: any): void {
    this.editingService = service;
    this.serviceForm = {
      category_id: service.category_id,
      name: service.name,
      description: service.description || '',
      price: service.price,
      estimated_time: service.estimated_time || '1 hora',
      status: service.status || 'active'
    };
    this.showServiceModal = true;
  }

  closeServiceModal(): void {
    this.showServiceModal = false;
    this.editingService = null;
  }

  saveService(): void {
    if (!this.serviceForm.name || !this.serviceForm.category_id) {
      this.showAlert('Preencha o nome do serviço e selecione a categoria.', 'error');
      return;
    }

    if (this.editingService) {
      this.apiService.updateProService(this.selectedProId, this.editingService.id, this.serviceForm).subscribe({
        next: () => {
          this.showAlert('Serviço atualizado com sucesso!');
          this.closeServiceModal();
          this.loadServices();
        },
        error: () => this.showAlert('Erro ao atualizar serviço.', 'error')
      });
    } else {
      this.apiService.createProService(this.selectedProId, this.serviceForm).subscribe({
        next: () => {
          this.showAlert('Serviço cadastrado com sucesso!');
          this.closeServiceModal();
          this.loadServices();
        },
        error: () => this.showAlert('Erro ao cadastrar serviço.', 'error')
      });
    }
  }

  deleteService(serviceId: number): void {
    if (confirm('Tem certeza que deseja excluir este serviço do seu catálogo?')) {
      this.apiService.deleteProService(this.selectedProId, serviceId).subscribe({
        next: () => {
          this.showAlert('Serviço excluído!');
          this.loadServices();
        },
        error: () => this.showAlert('Erro ao excluir serviço.', 'error')
      });
    }
  }

  toggleServiceStatus(service: any): void {
    const newStatus = service.status === 'active' ? 'inactive' : 'active';
    const payload = { ...service, status: newStatus };
    this.apiService.updateProService(this.selectedProId, service.id, payload).subscribe({
      next: () => {
        service.status = newStatus;
        this.showAlert(`Status alterado para ${newStatus === 'active' ? 'Ativo' : 'Inativo'}.`);
      }
    });
  }

  // --- PRODUTOS E PEÇAS ---
  openNewProductModal(): void {
    this.editingProduct = null;
    this.productForm = {
      category_id: this.categories.length > 0 ? this.categories[0].id : 1,
      name: '',
      description: '',
      price: 150,
      stock: 5,
      brand: '',
      compatible_model: '',
      status: 'active'
    };
    this.showProductModal = true;
  }

  openEditProductModal(product: any): void {
    this.editingProduct = product;
    this.productForm = {
      category_id: product.category_id,
      name: product.name,
      description: product.description || '',
      price: product.price,
      stock: product.stock,
      brand: product.brand || '',
      compatible_model: product.compatible_model || '',
      status: product.status || 'active'
    };
    this.showProductModal = true;
  }

  closeProductModal(): void {
    this.showProductModal = false;
    this.editingProduct = null;
  }

  saveProduct(): void {
    if (!this.productForm.name || !this.productForm.category_id) {
      this.showAlert('Preencha o nome do produto e selecione a categoria.', 'error');
      return;
    }

    if (this.editingProduct) {
      this.apiService.updateProProduct(this.selectedProId, this.editingProduct.id, this.productForm).subscribe({
        next: () => {
          this.showAlert('Produto/Peça atualizada com sucesso!');
          this.closeProductModal();
          this.loadProducts();
        },
        error: () => this.showAlert('Erro ao atualizar produto.', 'error')
      });
    } else {
      this.apiService.createProProduct(this.selectedProId, this.productForm).subscribe({
        next: () => {
          this.showAlert('Produto/Peça cadastrada com sucesso!');
          this.closeProductModal();
          this.loadProducts();
        },
        error: () => this.showAlert('Erro ao cadastrar produto.', 'error')
      });
    }
  }

  deleteProduct(productId: number): void {
    if (confirm('Tem certeza que deseja excluir este produto do seu estoque?')) {
      this.apiService.deleteProProduct(this.selectedProId, productId).subscribe({
        next: () => {
          this.showAlert('Produto/Peça excluída!');
          this.loadProducts();
        },
        error: () => this.showAlert('Erro ao excluir produto.', 'error')
      });
    }
  }

  toggleProductStatus(product: any): void {
    const newStatus = product.status === 'active' ? 'inactive' : 'active';
    const payload = { ...product, status: newStatus };
    this.apiService.updateProProduct(this.selectedProId, product.id, payload).subscribe({
      next: () => {
        product.status = newStatus;
        this.showAlert(`Status alterado para ${newStatus === 'active' ? 'Ativo' : 'Inativo'}.`);
      }
    });
  }

  // --- SEED DE SUGESTÕES POPULARES ---
  seedDefaults(categoryId: number = 1): void {
    if (confirm('Deseja carregar sugestões automáticas de serviços e peças para esta categoria?')) {
      this.loading = true;
      this.apiService.seedProDefaults(this.selectedProId, categoryId).subscribe({
        next: (res) => {
          this.showAlert(res.message || 'Sugestões carregadas com sucesso!');
          this.loadProCatalog();
        },
        error: () => {
          this.showAlert('Erro ao carregar sugestões.', 'error');
          this.loading = false;
        }
      });
    }
  }

  // Getters para filtragem
  get filteredServices(): any[] {
    if (!this.searchQuery.trim()) return this.services;
    const q = this.searchQuery.toLowerCase();
    return this.services.filter(s =>
      s.name.toLowerCase().includes(q) ||
      (s.category_name && s.category_name.toLowerCase().includes(q)) ||
      (s.description && s.description.toLowerCase().includes(q))
    );
  }

  get filteredProducts(): any[] {
    if (!this.searchQuery.trim()) return this.products;
    const q = this.searchQuery.toLowerCase();
    return this.products.filter(p =>
      p.name.toLowerCase().includes(q) ||
      (p.brand && p.brand.toLowerCase().includes(q)) ||
      (p.compatible_model && p.compatible_model.toLowerCase().includes(q))
    );
  }
}
