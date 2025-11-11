import { api, getServerUrl, getUiUrl } from "$lib/shared/utils/api";
import { writable } from "svelte/store";
import type { BillingPlan } from "./types";
import { pushError } from "$lib/shared/stores/feedback";

export const currentPlans = writable<BillingPlan[]>([]);

export async function getCurrentBillingPlans(): Promise<BillingPlan[]> {
    const result = await api.request<BillingPlan[]>(
        `/billing/plans`,
        currentPlans,
        (currentPlans) => currentPlans,
        {
            method: 'GET'
        }
    );

    if (result && result.success && result.data) {
        return result.data;
    }
    return [];
}

export async function checkout(plan: BillingPlan): Promise<string | null> {
    const result = await api.request<string>(
        `/billing/checkout`,
        null,
        null,
        {
            method: 'POST', body: JSON.stringify({plan, url: getUiUrl()})
        }
    );

    if (result && result.success && result.data) {
        return result.data;
    }
    pushError(`Error getting checkout URL: ${result?.error}. Please try again.`)
    return null;
}