class SearchAnalytics {
  constructor() {
    this.debounceTime = 250;
    this.timer = null;
    this.minLength = 3;
    this.hasSearched = false;
    
    this.searchInput = document.getElementById('searchInput');
    this.analyticsData = document.getElementById('analyticsData');
    this.refreshBtn = document.getElementById('refreshBtn');
    this.initialMessage = document.getElementById('initialMessage');
    this.loadingIndicator = document.getElementById('loadingIndicator');
    
    this.initEventListeners();
    this.loadInitialData();
  }

  initEventListeners() {
    this.searchInput.addEventListener('input', () => {
      clearTimeout(this.timer);
      this.timer = setTimeout(() => this.handleSearch(), this.debounceTime);
    });
    
    this.refreshBtn.addEventListener('click', () => this.loadAnalytics());
  }

  showLoading() {
    this.loadingIndicator.classList.add('active');
  }

  hideLoading() {
    this.loadingIndicator.classList.remove('active');
  }

  async loadInitialData() {
    this.showLoading();
    try {
      const response = await fetch('/analytics');
      const data = await response.json();
      if (Object.keys(data.searches).length > 0) {
        this.renderAnalytics(data.searches);
        this.initialMessage.classList.add('hidden');
      }
    } catch (error) {
      console.error('Error loading initial data:', error);
    } finally {
      this.hideLoading();
    }
  }

  async handleSearch() {
    const query = this.searchInput.value.trim();
    
    if (query.length >= this.minLength) {
      this.showLoading();
      try {
        await this.trackSearch(query);
        this.hasSearched = true;
        this.initialMessage.classList.add('hidden');
        await this.loadAnalytics();
      } catch (error) {
        console.error('Search error:', error);
      } finally {
        this.hideLoading();
      }
    }
  }

  async trackSearch(query) {
    const response = await fetch('/track_query', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ query })
    });
    
    if (!response.ok) throw new Error('Failed to track search');
  }

  async loadAnalytics() {
    this.showLoading();
    try {
      const response = await fetch('/analytics');
      const data = await response.json();
      this.renderAnalytics(data.searches);
    } catch (error) {
      console.error('Error loading analytics:', error);
    } finally {
      this.hideLoading();
    }
  }

  renderAnalytics(searches) {
    if (!searches || Object.keys(searches).length === 0) {
      this.analyticsData.innerHTML = '<p>No search history yet</p>';
      return;
    }

    this.analyticsData.innerHTML = `
      <ul class="analytics-list">
        ${Object.entries(searches).map(([query, count]) => `
          <li class="search-item">
            <span class="search-query">${this.escapeHtml(query)}</span>
            <span class="search-count">${count} search${count !== 1 ? 'es' : ''}</span>
          </li>
        `).join('')}
      </ul>
    `;
  }

  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
}

document.addEventListener('DOMContentLoaded', () => new SearchAnalytics());