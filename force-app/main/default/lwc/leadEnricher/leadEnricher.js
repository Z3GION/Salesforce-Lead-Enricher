import { LightningElement, track } from 'lwc';
import fetchNews from '@salesforce/apex/LeadEnrichmentController.fetchNews';
import createLead from '@salesforce/apex/LeadEnrichmentController.createLead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LeadEnricher extends LightningElement {
    @track searchTerm = '';
    @track results = [];
    @track isLoading = false;
    hasNoResults = false;

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    async handleSearch() {
        if (!this.searchTerm) {
            this.showToast('Error', 'Please enter a search term', 'error');
            return;
        }

        this.isLoading = true;
        this.hasNoResults = false;
        this.results = [];

        try {
            const data = await fetchNews({ searchTerm: this.searchTerm });
            if (data && data.length > 0) {
                this.results = data.map(article => ({
                    ...article,
                    isCreated: false
                }));
            } else {
                this.hasNoResults = true;
            }
        } catch (error) {
            this.showToast('Error', 'Error fetching news: ' + (error.body ? error.body.message : error.message), 'error');
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleCreateLead(event) {
        const index = event.target.dataset.index;
        const article = this.results[index];

        this.isLoading = true;

        const leadData = {
            FirstName: 'Lead from',
            LastName: article.source,
            Company: article.source,
            SourceUrl: article.url
        };

        try {
            await createLead({ leadData: leadData });
            this.showToast('Success', 'Lead created successfully!', 'success');

            // Update UI to show created
            this.results[index].isCreated = true;
            this.results = [...this.results]; // Trigger reactivity

        } catch (error) {
            this.showToast('Error', 'Error creating lead: ' + (error.body ? error.body.message : error.message), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
