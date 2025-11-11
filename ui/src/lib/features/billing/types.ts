export interface BillingPlan {
    price: {
        cents: number,
        rate: string
    },
    trial_days: number
    type: string
}

export function formatPrice(cents: number, rate: string): string {
    return `${cents/100} per ${rate}`
}